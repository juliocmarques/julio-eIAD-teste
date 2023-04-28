# Setting Up The CI/CD pipelines:

To get started with setting up your deployment pipelines please take the following steps:

## Azure DevOps Pipelines

### CI/CD for main branch

1. Create an environment called shared in `Pipelines -> Environments -> New environment`.
2. Create a pipeline in `Pipelines -> Pipelines -> New pipeline`. This should point to the [./pipelines/azdo.yml](./pipelines/main.yml) configuration file.
3. Configure a new environment file in [/scripts/environments](../scripts/environments/) called **shared.env**. The file can be based on [local.env.sample](../scripts/environments/local.env.example)
4. Set up the pipeline variables:
    - CLIENT_ID, CLIENT_SECRET: These are used for the deployment scripts to login to Azure. This is typically a service principal and will need Contributor access as a minimum
    - RESOURCE_GROUP_CONTRIBUTORS: When we create the infrastructure we grant an AAD group to have permissions on the created resources.
    - SUBSCRIPTION_ID: The ID of the subscription that should be deployed to.
    - TENANT_ID: The ID of the tenant that should be deployed to.
    - TF_BACKEND_ACCESS_KEY: Terraform is used to create Infrastructure as Code. This is the key to the Terraform State in a Storage Accouunt.
    - TF_BACKEND_CONTAINER: Terraform is used to create Infrastructure as Code. This is the container that the Terraform State is stored within a Storage Accouunt.
    - TF_BACKEND_RESOURCE_GROUP: Terraform is used to create Infrastructure as Code. This is the resource group that the Terraform State is stored within a Storage Accouunt.
    - TF_BACKEND_STORAGE_ACCOUNT: Terraform is used to create Infrastructure as Code. This is the storage account that the Terraform State is stored.

### CI/CD for pull requests

1. Create an environment called tmp in `Pipelines -> Environments -> New environment`.
2. Create a pipeline in `Pipelines -> Pipelines -> New pipeline`. This should point to the [./pipelines/pr.yml](../pipelines/pr.yml) configuration file.
3. Configure a new environment file in [/scripts/environments](../scripts/environments/) called **tmp.env**. The file can be based on [local.env.sample](../scripts/environments/local.env.example)
4. Set up the pipeline variables:
    - CLIENT_ID, CLIENT_SECRET: These are used for the deployment scripts to login to Azure. This is typically a service principal and will need Contributor access as a minimum
    - RESOURCE_GROUP_CONTRIBUTORS: When we create the infrastructure we grant an AAD group to have permissions on the created resources.
    - SUBSCRIPTION_ID: The ID of the subscription that should be deployed to.
    - TENANT_ID: The ID of the tenant that should be deployed to.
    - TF_BACKEND_ACCESS_KEY: Terraform is used to create Infrastructure as Code. This is the key to the Terraform State in a Storage Accouunt.
    - TF_BACKEND_CONTAINER: Terraform is used to create Infrastructure as Code. This is the container that the Terraform State is stored within a Storage Accouunt.
    - TF_BACKEND_RESOURCE_GROUP: Terraform is used to create Infrastructure as Code. This is the resource group that the Terraform State is stored within a Storage Accouunt.
    - TF_BACKEND_STORAGE_ACCOUNT: Terraform is used to create Infrastructure as Code. This is the storage account that the Terraform State is stored.