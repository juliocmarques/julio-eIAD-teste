"""
Tests orchestration
"""
import os
import asyncio
import requests
from datetime import datetime
import pytz
from azure.storage.filedatalake import FileSystemClient
from azure.cli.core import get_default_cli
import json

class TestOrchestrator:
    """
    Class for uploading test data and triggering tests

    Required positional args
    ------------------------
    synapse_endpoint -- endpoint for Azure Syanpse Workspace
    pipeline_name -- the name of the pipeline in Synapse to be ran
    input_fs_client -- file_system_client for the input container
    input_dir -- name of the directory to create for test data
    output_fs_client -- file_system_client for the output container
    output_dir -- name of the directory where output of the pipelines will be created
    test_type -- type of the test to run (either 'functional' or 'performance')
    disable_cleanup -- set to true to persist test input & output data at the end of the test run
    """
    def __init__(
        self,
        synapse_endpoint: str,
        synapse_parameters: str,
        pipeline_name: str,
        input_fs_client: FileSystemClient,
        input_dir: str,
        output_fs_client: FileSystemClient,
        output_dir: str,
        test_type: str,
        disable_cleanup: bool
    ):
        # Instance vars
        self.test_list = []
        self.tests_start_time = ''
        self.synapse_enpoint = synapse_endpoint
        self.pipeline_name = pipeline_name
        self.synapse_parameters = synapse_parameters
        self.input_fs_client = input_fs_client
        self.input_dir = input_dir
        self.output_fs_client = output_fs_client
        self.output_dir = output_dir

        self.disable_cleanup = disable_cleanup

        # Create input and output directory clients
        self.input_dir_client = input_fs_client.get_directory_client(input_dir)
        self.output_dir_client = output_fs_client.get_directory_client(output_dir)

    def upload_test_data(self, test_data_path):
        """
        Upload test data folder to input directory
        """
        # Ensure directory is clean (a previous test may not have completed gracefully)
        self.cleanup_input()

        # Create the folder for test data
        self.input_dir_client.create_directory()

        # Iterate through local folders and files and upload
        for foldername in os.listdir(test_data_path):
            sub_dir_client = self.input_dir_client.create_sub_directory(foldername)
            
            for filename in os.listdir(os.path.join(test_data_path, foldername)):
                with open(os.path.join(test_data_path, foldername, filename), 'rb') as file:
                    with sub_dir_client.get_file_client(filename) as file_client:
                        file_client.upload_data(file.read(), overwrite=True)
            
    def add_tests(self, tests):
        """
        Add an array of SynapsePipelineTests to the test list
        """
        self.test_list += tests

    async def start(self):
        """
        Starts the tests by uploading a manifest.txt file to input file system
        and then monitors tests for completion
        """
        # Before we run the tests, make sure no left over blobs exist in output
        self.cleanup_output()

        self.tests_start_time = datetime.now(pytz.UTC)

        json_params = json.loads(self.synapse_parameters)

        #Kick off the pipeline using the REST API
        synapse_pipeline_api = self.synapse_enpoint + "/pipelines/" + self.pipeline_name + "/createRun?api-version=2020-12-01"
        az_cli_args = ['account', 'get-access-token', '--resource', 'https://dev.azuresynapse.net', '--query', 'accessToken', '--output', 'tsv']
        cli = get_default_cli()
        cli.invoke(az_cli_args, out_file = open(os.devnull, 'w'))
        bearer_token = cli.result.result
        response = requests.post(synapse_pipeline_api, headers={'Content-Type': 'application/json', 'Authorization': f'Bearer {bearer_token}'}, json=json_params)

        # Execute tests in parallel
        test_tasks = []
        for test in self.test_list:
            task = asyncio.create_task(test.has_passed(self.tests_start_time))
            test_tasks.append(task)

        # Wait for all tests to either pass or fail
        test_results = await asyncio.gather(*test_tasks)

        # Once all tests are completed, clean input test_data and output blobs
        self.cleanup_input()
        self.cleanup_output()

        # Then return results for handling
        return test_results

    def cleanup_input(self):
        """
        Deletes all output blobs created for test
        """
        if self.disable_cleanup:
            print("Cleanup is disabled.")
            return

        # Delete input directory
        if self.input_dir_client.exists():
            self.input_dir_client.delete_directory()
            print("Cleaned up test input files.")


    def cleanup_output(self):
        """
        Deletes all input blobs created for test
        """
        if self.disable_cleanup:
            print("Cleanup is disabled.")
            return

        # Delete blobs outputted by tests
        if self.output_dir_client.exists():
            self.output_dir_client.delete_directory()
            print("Cleaned up test output files.")