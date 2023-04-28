output "resource_group_name" {
  value = azurerm_resource_group.eiad.name
}

output "location" {
  value = azurerm_resource_group.eiad.location
}

output "storage_account_id" {
  value = module.data_storage.storage_account_id
}

output "storage_account_name" {
  value = module.data_storage.storage_account_name
}

output "storage_account_key" {
  value     = module.data_storage.storage_account_key
  sensitive = true
}

output "storage_account_connection_string" {
  value     = module.data_storage.storage_account_connection_string
  sensitive = true
}

output "storage_account_sas" {
  value     = module.data_storage.storage_sas
  sensitive = true
}

output "key_vault_name" {
  value = module.key_vault.key_vault_name
}

output "key_vault_uri" {
  value = module.key_vault.key_vault_uri
}

output "spark_pool_name" {
  value = module.synapse.spark_pool_name
}

output "synapse_workspace_id" {
  value = module.synapse.synapse_workspace_id
}

output "synapse_workspace_name" {
  value = module.synapse.synapse_workspace_name
}

output "synapse_workspace_endpoint" {
  value = module.synapse.synapse_connectivity_endpoints["dev"]
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "azure_monitor_workspace_id" {
  value = module.azure_monitor.workspace_id
}

output "synapse_spark_node_count" {
  value = var.node_count
}

output "synapse_sql_username" {
  value = module.synapse.sql_username
}

output "synapse_sql_password" {
  value     = module.synapse.sql_password
  sensitive = true
}

output "synapse_sql_serverless_endpoint" {
  value = module.synapse.synapse_connectivity_endpoints.sqlOnDemand
}
