from datetime import datetime, timedelta
import pytz
from tabulate import tabulate
from azure.synapse.artifacts import ArtifactsClient
from azure.synapse.artifacts.models import RunFilterParameters, RunQueryFilter
from azure.storage.filedatalake import FileSystemClient
from typing import List


class PipelineTest:
    """
    Base class for various pipeline tests.
    Checks status in Synapse of pipeline and triggers.
    Derived classes must implement the has_passed() method.

    Required positional args
    ------------------------
    test_name -- test_name for the test (for logging purposes)
    artifacts_client -- an instance of ArtifactsClient initialised with the dev endpoint for the Synapse workspace
    triggers -- a list of triggers to monitor
    pipelines -- a list of pipelines to monitor

    Optional args
    -------------
    timeout -- amount of seconds to wait for pipeline to complete before failing (default: 1400)
    """
    def __init__(
        self,
        test_name: str,
        artifacts_client: ArtifactsClient,
        triggers=None,
        pipelines=None
    ):
        # Instance vars
        self.test_name = test_name
        self.triggers = triggers
        self.pipelines = pipelines

        self.artifacts_client = artifacts_client

    async def has_passed(self, start_time: datetime):
        raise NotImplementedError()

    def check_synapse_status(self, artifact_type: str, names: List[str], start_time: datetime):
        """
        Checks the status of pipelines or triggers

        Positional args
        ---------------
        artifact_type -- pipeline or trigger
        names -- list of names to query for
        start_time -- the start_time of the test
        """
        operand = ''
        if artifact_type == 'trigger':
            operand = 'TriggerName'
        elif artifact_type == 'pipeline':
            operand = 'PipelineName'

        # Construct query for pipelines we want to monitor
        name_query = RunQueryFilter(
            operand=operand,
            operator='Equals',
            values=names)

        filters = RunFilterParameters(
            last_updated_after=start_time.isoformat(),
            last_updated_before=datetime.now(pytz.UTC).isoformat(),
            filters=[name_query])

        # Get pipeline/trigger runs
        runs = []
        if artifact_type == 'trigger':
            runs = self.artifacts_client.trigger_run \
                       .query_trigger_runs_by_workspace(filters)
        elif artifact_type == 'pipeline':
            runs = self.artifacts_client.pipeline_run \
                       .query_pipeline_runs_by_workspace(filters)

        # Check if any pipelines/triggers have started and whether they've failed
        if len(runs.value) > 0:
            started = False
            failed = False
            messages = []

            # Loop through runs to check status
            for run in runs.value:
                if artifact_type == 'trigger':
                    messages.append([run.trigger_name, run.status, run.message])
                elif artifact_type == 'pipeline':
                    messages.append([run.pipeline_name, run.status, run.message])

                if run.status == 'Failed':
                    failed = True
                elif run.status == 'Inprogress' or run.status == 'Succeeded':
                    started = True

            # Log status
            print(f'{self.test_name}: checked status of {artifact_type}s:\n' + \
                  tabulate(messages, headers=[artifact_type.capitalize(), 'Status', 'Message']) \
                  + '\n')

            if failed:
                print(f'{self.test_name}: one or more {artifact_type}s have failed.')
                return started, True, messages
            else:
                return started, False, messages
        else:
            print(f'{self.test_name}: no {artifact_type} runs detected yet.')
            return False, False, []