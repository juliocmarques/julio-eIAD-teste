output "key_vault_id" {
  value = azurerm_key_vault.eiad_kv.id
}

output "key_vault_name" {
  value = azurerm_key_vault.eiad_kv.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.eiad_kv.vault_uri
}
