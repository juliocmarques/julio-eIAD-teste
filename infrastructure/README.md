# Configure Azure resources

Now that your Dev Container and ENV files are conigured, it is time to deploy the Azure resources. This is done using a `Makefile`.

To deploy everything run the following command from the Dev Container bash prompt:

```bash
    make deploy
```

This will deploy the infrastructure and the application code.

*This command can be ran as many times as needed in the event you encounter any errors. A set of known issues and their workarounds that we have found can be found in [Known Issues](../docs/knownissues.md)*

---

At this point this step is complete, please return to the [checklist](../README.md#deployment)) and complete the next step.

## Additional Information

For a full set of Makefile rules, run `make help`.

``` bash
vscode ➜ /workspaces/eIAD (main ✗) $ make help
help                      Show this help
deploy                    Deploy infrastructure and application code
infrastructure            Deploy infrastructure
clean-infrastructure      Remove deployed infrastructure
tf-format                 Apply formatting to Terraform files
inf-output                Get infrastructure outputs
deploy-sql-database       Deploys the Azure Synapse serverless SQL database
deploy-synapse-artifacts  Deploys Sypapse Artifacts
clean-synapse-artifacts   Remove Synapse artifacts from deployment
deploy-synapse-packages   Deploys Sypapse Packages
pull-synapse-artifacts    Pulls Synapse artifacts from linked deployment
extract-env               Extract infrastructure.env file from terraform output
functional-tests          Run functional tests to check the processing pipeline is working
```
