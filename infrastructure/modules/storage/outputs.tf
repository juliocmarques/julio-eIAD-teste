output "storage_account_name" {
  value = azurerm_storage_account.eiad.name
}

output "adls_filesystem_ids" {
  value = tomap({
    for k, filesystem in azurerm_storage_data_lake_gen2_filesystem.filesystem : k => filesystem.id
  })
}

output "storage_account_id" {
  value = azurerm_storage_account.eiad.id
}

output "storage_account_key" {
  value     = azurerm_storage_account.eiad.primary_access_key
  sensitive = true
}

output "storage_account_connection_string" {
  value     = azurerm_storage_account.eiad.primary_connection_string
  sensitive = true
}

output "storage_sas" {
  value = data.azurerm_storage_account_sas.sas.sas
}

output "primary_dfs_endpoint" {
  value = azurerm_storage_account.eiad.primary_dfs_endpoint
}
