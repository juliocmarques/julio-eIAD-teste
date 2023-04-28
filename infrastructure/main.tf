data "azurerm_client_config" "current" {}

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
  number  = false
}

resource "azurerm_resource_group" "eiad" {
  name     = var.resource_group_name
  location = var.location
  tags = merge(
    var.tags,
    {
      BuildNumber = var.build_number
    },
  )
}

resource "azurerm_role_assignment" "resource_group_contributor" {
  for_each             = toset(var.resource_group_contributors)
  scope                = azurerm_resource_group.eiad.id
  role_definition_name = "Contributor"
  principal_id         = each.key
}

module "azure_monitor" {
  source              = "./modules/monitor"
  workspace_name      = "eiad-monitor-${random_string.random.result}"
  insight_name        = "eiad-insights-${random_string.random.result}"
  location            = azurerm_resource_group.eiad.location
  resource_group_name = azurerm_resource_group.eiad.name
  tags                = var.tags
}

module "data_storage" {
  source              = "./modules/storage"
  location            = azurerm_resource_group.eiad.location
  resource_group_name = azurerm_resource_group.eiad.name
  random_string       = random_string.random.result
  storage_name_prefix = "eiaddata"
  storage_containers  = []
  adls_filesystems    = ["input", "output", "working", "synapse", "model"]
  tags                = var.tags
  is_hns_enabled      = true
  replication_type    = "GRS"
}

# required for the Synapse triggers to register blob changed events
resource "azurerm_role_assignment" "data_storage_contributor" {
  scope                = module.data_storage.storage_account_id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

module "key_vault" {
  source              = "./modules/key-vault"
  depends_on          = [module.data_storage]
  location            = azurerm_resource_group.eiad.location
  resource_group_name = azurerm_resource_group.eiad.name
  random_string       = random_string.random.result
  tags                = var.tags
  secrets = {
    "BlobStorageConnectionString"  = module.data_storage.storage_account_connection_string
    "StorageAccountKey"            = module.data_storage.storage_account_key
    "StorageAccountName"           = module.data_storage.storage_account_name
    "ResourceGroupName"            = azurerm_resource_group.eiad.name
    "SubscriptionId"               = data.azurerm_client_config.current.subscription_id
    "SynapseSQLPassword"           = module.synapse.sql_password
    "SynapseSQLUserName"           = module.synapse.sql_username
    "SyanpseServerlessSQLEndpoint" = module.synapse.synapse_connectivity_endpoints.sqlOnDemand
    "TenantID"                     = data.azurerm_client_config.current.tenant_id
    "ADAppRegClientId"             = data.azurerm_client_config.current.client_id
    "LogAnalyticsWorkspaceKey"     = module.azure_monitor.primary_shared_key
    "AppInsightsConnectionString"  = module.azure_monitor.instrumentation_connection_string
  }
}

module "synapse" {
  source                     = "./modules/synapse"
  depends_on                 = [module.data_storage, null_resource.register_adf_provider]
  location                   = azurerm_resource_group.eiad.location
  resource_group_name        = azurerm_resource_group.eiad.name
  random_string              = random_string.random.result
  key_vault_name             = module.key_vault.key_vault_name
  storage_account_id         = module.data_storage.storage_account_id
  storage_account_name       = module.data_storage.storage_account_name
  adls_filesystem_id         = module.data_storage.adls_filesystem_ids["synapse"]
  primary_dfs_endpoint       = module.data_storage.primary_dfs_endpoint
  node_count                 = var.node_count
  azure_monitor_workspace_id = module.azure_monitor.workspace_id
  tags                       = var.tags
  storage_sas_token          = module.data_storage.storage_sas

  storage_contributors = var.is_local ? [data.azurerm_client_config.current.object_id] : var.resource_group_contributors

  # When we are running locally, the running user will be Synapse Administrator, so we
  # dont want to be a Synapse Contributor too, so supply an empty set.
  synapse_contributors = []
  # dont want to be a Synapse Credential User too, so supply an empty set.
  synapse_credential_users = var.is_local ? [data.azurerm_client_config.current.object_id] : var.resource_group_contributors
}

# It is required to register the Azure Data Factory resource provider in the subscription for Azure Synapse to ADLS storage triggers. 
# Synpase does not auto register the ADF resource provider, so requires manaul registration. 
resource "null_resource" "register_adf_provider" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
    adfproviderid=$(az provider show --namespace "Microsoft.DataFactory" --output tsv --query "id")
    if [ $adfproviderid == "" ] 
    then
      echo "Registering Azure Data Factory resource provider in subscription."
      az provider register --namespace "Microsoft.DataFactory"
    fi
  EOT
  }
  triggers = {
    always_run = timestamp()
  }
}