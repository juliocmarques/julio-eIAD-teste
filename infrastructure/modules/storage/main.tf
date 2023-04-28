resource "azurerm_storage_account" "eiad" {
  name                     = "${var.storage_name_prefix}${var.random_string}"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = var.replication_type
  tags                     = var.tags
  is_hns_enabled           = var.is_hns_enabled
}

resource "azurerm_storage_container" "containers" {
  for_each              = toset(var.storage_containers)
  name                  = each.key
  storage_account_name  = azurerm_storage_account.eiad.name
  container_access_type = "private"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "filesystem" {
  for_each           = toset(var.adls_filesystems)
  name               = each.key
  storage_account_id = azurerm_storage_account.eiad.id
}

data "azurerm_storage_account_sas" "sas" {
  connection_string = azurerm_storage_account.eiad.primary_connection_string
  https_only        = true
  start             = "2022-01-01"
  expiry            = "2099-06-30"
  resource_types {
    object    = true
    container = true
    service   = true
  }
  services {
    blob  = true
    queue = false
    table = false
    file  = true
  }
  permissions {
    read    = true
    write   = false
    delete  = false
    list    = true
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}
