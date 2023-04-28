SHELL := /bin/bash

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%s\033[0m|%s\n", $$1, $$2}' \
        | column -t -s '|'

deploy: infrastructure extract-env deploy-sql-database deploy-synapse-packages deploy-synapse-artifacts ## Deploy infrastructure and application code

infrastructure: check-subscription tf-format ## Deploy infrastructure
	@./scripts/inf-create.sh

clean-infrastructure: ## Remove deployed infrastructure
	@./scripts/inf-cleanup.sh

tf-format: ## Apply formatting to Terraform files
	@./scripts/terraform-format.sh

inf-output: ## Get infrastructure outputs
	@./scripts/inf-output.sh

deploy-sql-database: check-subscription extract-env ## Deploys the Azure Synapse serverless SQL database
	@./scripts/deploy-sql-database.sh

deploy-synapse-artifacts: check-subscription extract-env ## Deploys Sypapse Artifacts
	@./scripts/deploy-synapse-artifacts.sh

clean-synapse-artifacts: check-subscription extract-env ## Remove Synapse artifacts from deployment
	@./scripts/clean-synapse-artifacts.sh

deploy-synapse-packages: check-subscription extract-env ## Deploys Sypapse Packages
	@./scripts/deploy-synapse-packages.sh

pull-synapse-artifacts: check-subscription extract-env ## Pulls Synapse artifacts from linked deployment
	@./scripts/download-synapse-artifacts.sh

extract-env: ## Extract infrastructure.env file from terraform output
	@./scripts/json-to-env.sh < inf_output.json > ./scripts/environments/infrastructure.env

functional-tests: extract-env ## Run functional tests to check the processing pipeline is working
	@./scripts/functional-tests.sh

# Utils (used by other Makefile rules)
check-subscription:
	@./scripts/check-subscription.sh

# CI rules (use by automated builds)
take-dir-ownership:
	@sudo chown -R vscode .

terraform-remote-backend:
	@mv ./infrastructure/backend.tf.ci ./infrastructure/backend.tf

infrastructure-remote-backend: terraform-remote-backend infrastructure

destroy-inf: check-subscription
	@./scripts/inf-destroy.sh