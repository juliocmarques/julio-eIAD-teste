import asyncio
import json
import os
from datetime import datetime, timedelta
from pathlib import Path
from jsondiff import diff

import pytz
from azure.storage.filedatalake import FileSystemClient
from azure.synapse.artifacts import ArtifactsClient
from jsonschema import SchemaError, ValidationError, validate

from pipeline_tests.pipeline_test import PipelineTest


# JSON keys to ignore when performing file comparison
MEDIA_PROCESSING_IGNORED_KEYS = {"batch_num", "media_enrichment"}
# Keeping media processing ignored keys separate, so they're explicit if they end up clobbering keys for other types

IGNORED_KEYS = {"X", "Y", "cluster", "file_path", "eventDate", "eventDetails", "batch_num", "batch_id", "analysis_results", "read_results", \
    "X_2", "Y_2", "X_3", "Y_3", "cluster_2", "cluster_3"}.union(MEDIA_PROCESSING_IGNORED_KEYS)

class CheckFile(PipelineTest):
    """
    Test pipelines by checking for presence of output file

    Required positional args
    ------------------------
    test_name -- test_name for the test (for logging purposes)
    checked_file -- path to the file to look for to indicate pipeline succes, relative ot the batch root
    checked_file_schema -- reference to json schema document to validate the output file against
    expected_dir -- path to batch root where the expected "canonical' files to compare to are
    output_dir -- path to batch root on the Azure FS
    timeout -- amount of seconds to wait for pipeline to complete before failing (default: 1200)
    output_fs_client -- a FileSystemClient initialised to work with output container
    artifacts_client -- an ArtifactsClient initialised to work with Synapse instance

    Optional args
    -------------
    ignore_synapse_query -- Do not make API calls to Synapse
    triggers -- a list of triggers to monitor 
    pipelines -- a list of pipelines to monitor
    """
    def __init__(
        self,
        test_name: str,
        checked_file: str,
        checked_file_schema: str,
        output_dir: str,
        timeout: timedelta,
        output_fs_client: FileSystemClient,
        artifacts_client: ArtifactsClient,
        expected_dir: str=None,
        ignore_synapse_query=False,
        triggers=None,
        pipelines=None
    ):
        super().__init__(
            test_name=test_name,
            artifacts_client=artifacts_client,
            triggers=triggers,
            pipelines=pipelines,
        )

        self.checked_file = checked_file
        self.checked_file_schema = checked_file_schema
        self.checked_file_path = '/'.join([output_dir, checked_file])
        self.checked_file_blob = output_fs_client.get_file_client(self.checked_file_path)
        self.expected_dir = expected_dir
        self.expected_file_path = os.path.join(expected_dir, checked_file) if expected_dir else None
        self.ignore_synapse_query = ignore_synapse_query
        self.timeout = timeout


    async def has_passed(self, start_time: datetime):
        """
        Check for test output to validate if it has passed or failed

        Positional args
        ---------------
        start_time -- the time the manifest file was uploaded to trigger the pipeline(s)
        """
        current_time = datetime.now(pytz.UTC).timestamp()
        end_time = current_time + self.timeout
        triggers_started = False

        # Poll for existence of expected output blob until the test times out
        print(f'Started {self.test_name} test: polling for output blob...')
        while current_time < end_time:

            # If expected output blob is found, note the time taken then complete
            if self.checked_file_blob.exists():
                end_time = datetime.now(pytz.UTC).timestamp()
                print((f'{self.test_name}: output blob found. Pipeline took '
                       f'{end_time - start_time.timestamp():0.4f} seconds to complete.'))

                checked_file_content = self.checked_file_blob.download_file().readall().decode('utf-8')
                checked_file_json = json.loads(checked_file_content)

                # Save a copy of the checked file locally for reference
                local_checked_file_path = os.path.join('./output', self.checked_file)
                Path(os.path.dirname(local_checked_file_path)).mkdir(parents=True, exist_ok=True)
                with open(local_checked_file_path, 'w') as json_file:
                    json_file.write(checked_file_content)

                # Validate the schema, if needed
                if self.checked_file_schema:
                    with open(self.checked_file_schema, 'r') as schema_file:
                        schema = json.loads(schema_file.read())
                        try:
                            validate(checked_file_json, schema)
                            print(f'Output JSON {self.checked_file} is valid against {self.checked_file_schema}')
                        except SchemaError as e:
                            print(f'Error in Schema doc: {self.checked_file_schema} - {e.message}')
                            print(f'File contents:\n{checked_file_content}')
                            return [self.test_name, 'failed']
                        except ValidationError as e:
                            print(f'Error validating {self.checked_file} - {e.message}')
                            print(f'File contents:\n{checked_file_content}')
                            return [self.test_name, 'failed']
                        
                if self.expected_dir:
                    with open(self.expected_file_path, 'r') as expected_file:
                        expected_file_json = json.loads(expected_file.read())

                    checked_file_json = {k: v for k, v in checked_file_json.items() if k not in IGNORED_KEYS}
                    expected_file_json = {k: v for k, v in expected_file_json.items() if k not in IGNORED_KEYS}


                    difference = diff(checked_file_json, expected_file_json)
                    if difference:
                        print(f"Difference between actual output {local_checked_file_path} and expected {self.expected_file_path}:\n", difference)
                        return [self.test_name, 'failed']
                    print(f'Output JSON {self.checked_file} matches expected file content {self.expected_file_path}')

                return [self.test_name, 'passed', f'{end_time - start_time.timestamp():0.4f}']

            # If blob isn't found, check the status of the trigger and pipeline
            if not self.ignore_synapse_query:
                try:
                    # Only check trigger status if it hasn't started yet
                    if not triggers_started:
                        started, failed, _ = self.check_synapse_status(
                            'trigger', self.triggers, start_time)
                        triggers_started = started

                        # If trigger(s) failed to start, fail the test
                        if failed:
                            return [self.test_name, 'failed']
                    else:
                        started, failed, _ = self.check_synapse_status(
                            'pipeline', self.pipelines, start_time)

                        # If pipeline(s) failed, end the test
                        if failed:
                            return [self.test_name, 'failed']
                except Exception as e: 
                    # Trap and print all errors, let failure happen due to timeout
                    print('An error occurred while querying synapse:')
                    print(str(e))

            # Otherwise log the time elapsed and sleep the thread for 5 seconds
            current_time = datetime.now(pytz.UTC).timestamp()
            print((f'{self.test_name} still running... '
                   f'Checking file {self.checked_file_path},'
                   f'(time elapsed: {current_time - start_time.timestamp():0.1f}s).'))
            await asyncio.sleep(5)

        print((f'{self.test_name}: timed out waiting for output blob to be created. '
                'This indicates pipeline has taken too long to complete.'))
        return [self.test_name, 'failed']
