import asyncio
from datetime import datetime, timedelta
from typing import List

import pytz
from azure.storage.filedatalake import FileSystemClient
from azure.synapse.artifacts import ArtifactsClient

from pipeline_tests.pipeline_test import PipelineTest


class CheckPipelineSuccess(PipelineTest):
    """
    Check for successful pipeline runs

    Required positional args
    ------------------------
    test_name -- test_name for the test (for logging purposes)
    timeout -- amount of seconds to wait for pipeline to complete before failing (default: 1200)
    artifacts_client -- an ArtifactsClient initialised to work with Synapse instance

    Optional args
    -------------
    triggers -- a list of triggers to monitor 
    pipelines -- a list of pipelines to monitor
    """

    def __init__(
        self,
        test_name: str,
        timeout: timedelta,
        artifacts_client: ArtifactsClient,
        triggers: List[str] = None,
        pipelines: List[str] = None
    ):
        super().__init__(
            test_name=test_name,
            artifacts_client=artifacts_client,
            triggers=triggers,
            pipelines=pipelines,
        )
        self.timeout = timeout

    async def has_passed(self, start_time: timedelta):
        """
        Check for test output to validate if it has passed or failed

        Positional args
        ---------------
        start_time -- the time the manifest file was uploaded to trigger the pipeline(s)
        """
        current_time = datetime.now(pytz.UTC).timestamp()
        end_time = current_time + self.timeout
        triggers_started = False
        if self.triggers is None:
            triggers_started = True

        # Poll for existence of expected output blob until the test times out
        print(f'Started {self.test_name} test: checking for Synapse pipeline(s) success...')
        while current_time < end_time:

            # Only check trigger status if it hasn't started yet
            if not triggers_started:
                started, failed, messages = self.check_synapse_status(
                    'trigger', self.triggers, start_time)
                triggers_started = started

                # If trigger(s) failed to start, fail the test
                if failed:
                    return [self.test_name, 'failed']
            else:
                started, failed, messages = self.check_synapse_status(
                    'pipeline', self.pipelines, start_time)

                # If pipeline(s) failed, end the test
                if failed:
                    return [self.test_name, 'failed']
                elif started:

                    # If all the pipelines have succeeded, pass the test
                    if all(message[1] == 'Succeeded' for message in messages):
                        end_time = datetime.now(pytz.UTC).timestamp()
                        print((f'{self.test_name}: all pipelines have succeeded. Took '
                            f'{end_time - start_time.timestamp():0.4f} seconds to complete.'))
                        return [self.test_name, 'passed', f'{end_time - start_time.timestamp():0.4f}']

            # Otherwise log the time elapsed and sleep the thread for 5 seconds
            current_time = datetime.now(pytz.UTC).timestamp()
            print((f'{self.test_name} still running... '
                    f'(time elapsed: {current_time - start_time.timestamp():0.1f}s).'))
            await asyncio.sleep(5)

        print((f'{self.test_name}: timed out waiting for output blob to be created. '
                'This indicates pipeline has taken too long to complete.'))
        return [self.test_name, 'failed']
