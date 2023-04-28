"""
Runs Synapse pipeline functional tests

Required positional args
------------------------
test_type: the type of test to run (performance or functional)
storage_name -- the name of the ADLS-enabled storage account for testing with
storage_key -- the account key of the storage account
synapse_endpoint -- the developer endpoint for the synapse workspace
test_data_dir -- path within input container test data is located or will be uploaded to
disable_cleanup -- set to true to persist test input & output data at the end of the test run
"""
import ast
import asyncio
import os
import sys
import uuid
import argparse
from typing import List

from azure.identity import AzureCliCredential
from azure.storage.filedatalake import DataLakeServiceClient, FileSystemClient
from azure.synapse.artifacts import ArtifactsClient
from tabulate import tabulate

from pipeline_tests.check_file import CheckFile
from pipeline_tests.check_pipeline_success import CheckPipelineSuccess
from test_orchestrator.test_orchestrator import TestOrchestrator

TIMEOUT_FUNCTIONAL_TESTS_SECONDS = 5400  # 90 minutes
TIMEOUT_PERFORMANCE_TESTS_SECONDS = 16200   # 4.5 hours
EXPECTED_TEST_DATA_DIR = './data/test_batch/'


def parse_arguments():
    """
    Parse command line arguments
    Note that extract_env must be ran before this script is invoked
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("--test_type", required=True, help="Type of the test to run (can be either 'performance' or 'functional')")
    parser.add_argument("--pipeline_name", required=True, help="The name of the pipeline to start in Synapse (set in local.env)")
    parser.add_argument("--storage_name", required=True, help="Name of storage account (set in extract-env)")
    parser.add_argument("--storage_key", required=True, help="Storage account key (set in extract-env)")
    parser.add_argument("--synapse_endpoint", required=True, help="Synapse endpoint to query (set in extract-env)")
    parser.add_argument("--synapse_parameters", required=False, help="Parameters as a JSON string to be passed to the syanpse_endpoint specified")
    parser.add_argument("--test_data_dir", required=True, help="Test data directory in input container")
    parser.add_argument("--disable_cleanup", type=lambda x: str(x).lower() == "true", default=False, help="Test data directory in input container")
    parser.add_argument("--ignore_synapse_query", type=lambda x: str(x).lower() == "true", default=False, help="Query Synapse endpoint in tests")

    args = parser.parse_args()

    if args.ignore_synapse_query:
        print('Running WITHOUT querying Synapse endpoint')
    else:
        print('Running WITH querying Synapse endpoint')

    return args


async def main():
    """
    Main asynchronous method for initiating tests
    """
    args = parse_arguments()

    # Create a blob client using the local file name as the name for the blob
    adls_service_client = DataLakeServiceClient(
        account_url=f'https://{args.storage_name}.dfs.core.windows.net',
        credential=args.storage_key)

    # Create file system clients for input, output & rules containers
    input_fs_client = adls_service_client.get_file_system_client('input')
    output_fs_client = adls_service_client.get_file_system_client('output')
    batch_num = str(uuid.uuid1()).replace("-", "_")

    output_data_dir = batch_num
    artifacts_client = ArtifactsClient(AzureCliCredential(), args.synapse_endpoint)

    # Create Test Orchestrator for uploading test data and starting test
    test_orchestrator = TestOrchestrator(args.synapse_endpoint, args.synapse_parameters, args.pipeline_name, input_fs_client, args.test_data_dir, 
                                         output_fs_client, output_data_dir,
                                         args.test_type, args.disable_cleanup)

    # Test flow ===================================================
    print(f'Running Synapse pipeline {args.test_type} tests...')

    # Add tests to execute depending on test_type
    if args.test_type == 'functional':

        # Upload test data from local directory
        test_orchestrator.upload_test_data(
            os.path.join(os.path.dirname(__file__), 'test_data'))

        test_orchestrator.add_tests([
            # Check pipeline runs successfully
            CheckPipelineSuccess(test_name='anomaly_detection',
                                 artifacts_client=artifacts_client,
                                 timeout=TIMEOUT_FUNCTIONAL_TESTS_SECONDS,
                                 pipelines=[args.pipeline_name],
                                 triggers=None)
        ])

    elif args.test_type == 'performance':
        test_orchestrator.add_tests([
            # Check pipeline runs successfully
            CheckPipelineSuccess(test_name='text_processing',
                                 artifacts_client=artifacts_client,
                                 timeout=TIMEOUT_PERFORMANCE_TESTS_SECONDS)
        ])
    else:
        print(f'{args.test_type} is not a valid test_type. Specify "performance" or "functional".')
        sys.exit(1)

    # Run tests asynchronously
    results = await test_orchestrator.start()

    # Check & handle results
    print('\n' + tabulate(results, headers=['Name', 'Result', 'Time taken (s)']))
    for result in results:
        if result[1] == 'failed':
            print('\nOne or more tests failed. Check the above output for more information.')
            sys.exit(1)


# Start the tests
asyncio.run(main())
