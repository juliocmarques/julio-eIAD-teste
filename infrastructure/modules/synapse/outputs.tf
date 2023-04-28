output "synapse_workspace_id" {
  value = azurerm_synapse_workspace.synapse_workspace.id
}

output "synapse_workspace_name" {
  value = azurerm_synapse_workspace.synapse_workspace.name
}

output "spark_pool_name" {
  value = azurerm_synapse_spark_pool.synapse_spark_pool.name
}

output "synapse_connectivity_endpoints" {
  value = azurerm_synapse_workspace.synapse_workspace.connectivity_endpoints
}

output "synapse_identity" {
  value = azurerm_synapse_workspace.synapse_workspace.identity
}

output "sql_password" {
  sensitive = true
  value     = random_password.sql_password.result
}

output "sql_username" {
  value = "sqladminuser"
}
