# Functional Testing

## Process

The functional testing process performs the following steps:

1. Data from the `test_data` directory is uploaded to the `functional_testing` directory in the `input` container
2. The processing pipeline configured in "PRIMARY_PIPELINE_NAME" is triggered.
3. The Synapse pipeline is continuously checked for completion

## Functional test setup

Simply run `make functional-tests` at the Bash prompt will run the preconfigured functional tests.

---

At this point this step is complete, please return to the [checklist](../#deployment) and complete the next step.

### Additional Information

There are a few options in `local.env` that can be configured to help with debugging etc.:

- `IGNORE_TEST_PIPELINE_QUERY=true` - skips checking Synapse for pipeline failure, which fails the tests before hitting the timeout. Useful when dealing with the Synapse API calls issues (such as a "400 Bad Request response")
- `DISABLE_TEST_CLEANUP=true` - overrides the default behavior of cleaning up the input and output data (that isn't desirable in a normal deployment) by default the functional tests clean up after themselves by getting rid of any input and output data created during the tests. Overiding this allows manual inspection of the files.

### Adding Additional Test Data

To add additional files to the test data, first run the new files normally through the processing pipeline. Then, add the new files to `test_data` directory, and add their ouput (from the previous pipeline run) to the appropriate directory in `data/test_batch`.
