data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "eiad_kv" {
  name                     = "eiad-keyvault-${var.random_string}"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = true
  tags                     = var.tags
}

resource "azurerm_key_vault_access_policy" "deploy_user_access_policy" {
  key_vault_id = azurerm_key_vault.eiad_kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get", "List", "Delete"
  ]

  secret_permissions = [
    "Get", "Set", "Delete", "List", "Purge", "Recover", "Restore"
  ]

  storage_permissions = [
    "Get", "List", "Delete"
  ]
}

resource "azurerm_key_vault_secret" "secret" {
  for_each     = var.secrets
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.eiad_kv.id
  depends_on = [
    azurerm_key_vault_access_policy.deploy_user_access_policy
  ]
}
