# Tests

This folder contains functional which are used to validate the pipeline works as designed.

## Functional tests

The functional tests are invoked both within a PR build and as needed throughout the development process. It is initiated through a `make functional-tests` command which calls the `.\scripts\functional-tests.sh` script, which in turn parses the Terraform outputs and environment variables and invokes the Python-based functional tests. The goal of these is to make sure that throughout our development cycle, any changes made does not effect the expected processing pipeline outputs from a pre-determined set of input files (located in `.\tests\test_data`).

Go [here](./FUNCTIONAL_TESTING.md) for more details on configuring and running functional tests.

## Adding tests

The test framework is written in a modular way to make it possible to add new tests in just a few steps.

### Add existing PipelineTests

Within the `.\tests\pipeline_tests` module, you'll find some existing tests for checking pipeline successes and output files, which can be configured with a range of arguments to inspect different aspects of the processing pipeline(s). Add more of them like so:

1. Open `run-tests.py`, then find the line that calls `test_orchestrator.add_tests()` for either `performance` or `functional` tests, depending on the type you wish to add to.
2. Within the tests list that's passed as an argument, you can add a new test by instantiating an instance of its class. For example, if you wanted the performance tests to also check for a specific output file, you would add `CheckForFile()` to the test list, passing the neccesary arguments.
3. That's it!

As the tests run asynchronously, you can add as many as you like and they will all run in parallel until the last one completes.

### Add a new type of PipelineTest

Within the `pipeline_tests` module, there is a `PipelineTest` base class. You can create a new class and inherit from this, then implement the `has_passed()` asynchronous method as you see fit, which should return `[ self.name, << BOOLEAN: passed or failed >>, << INT: seconds took to complete (if successful) >> ]`.

Then, add this new test to the relevant `add_tests()` call within `run-tests.py`, and when you next run your tests the `TestOrchestrator` will call the new test and wait for it to return a pass or fail.
