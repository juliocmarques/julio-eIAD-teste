data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

resource "random_password" "sql_password" {
  length           = 16
  special          = true
  min_special      = 1
  lower            = true
  min_lower        = 1
  upper            = true
  min_upper        = 1
  override_special = "!$#%"
}

resource "azurerm_synapse_workspace" "synapse_workspace" {
  name                                 = "eiad-synapse-${var.random_string}"
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = var.adls_filesystem_id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = random_password.sql_password.result
  managed_virtual_network_enabled      = "false"
  managed_resource_group_name          = "${var.resource_group_name}-synapse"
  tags                                 = var.tags
  public_network_access_enabled        = true

  identity {
    type = "SystemAssigned"
  }
}

# The properties set here on the Synapse Spark Pool are also defined in /scripts/deploy-synapse-packages.sh due to a requirement to use the REST APIs. 
# Ensure if you change a property here that you also update in the script to match. 
resource "azurerm_synapse_spark_pool" "synapse_spark_pool" {
  name                                = "eiadsparkpool"
  synapse_workspace_id                = azurerm_synapse_workspace.synapse_workspace.id
  node_size_family                    = "MemoryOptimized"
  node_size                           = "Large"
  tags                                = var.tags
  cache_size                          = 0
  compute_isolation_enabled           = false
  dynamic_executor_allocation_enabled = false
  session_level_packages_enabled      = true
  spark_version                       = "3.2"
  node_count                          = var.node_count

  auto_pause {
    delay_in_minutes = 15
  }

  # library_requirement {
  # Don't add Library requirements here as we update packages later which rebuild the cluster.
  # By keeping the cluster as vanilla as possible at this point will save you a lot of time later.  
  # }
  lifecycle {
    ignore_changes = [
      # ignore changes to library_requirement as we update them outside of Terraform
      library_requirement,
    ]
  }

  spark_config {
    content = templatefile("${path.root}/../synapse/spark_pool/config.txt", {
      storage_account_name       = var.storage_account_name
      azure_monitor_workspace_id = var.azure_monitor_workspace_id
      key_vault_name             = var.key_vault_name
    })
    filename = "config.txt"
  }

  # When a Spark Pool is destroyed (i.e. a change in config requires re-creating), the destroy operation will fail if
  # artifacts like notebooks are linked to it. To prevent this we must destroy those artifacts first
  # (since they are re-deployed in the pipeline anyway)
  provisioner "local-exec" {
    when        = destroy
    working_dir = "${path.root}/.."
    command     = "make clean-synapse-artifacts"
  }

  # We also need to add a depends_on firewall rule as the Synapse clean-up script will fail if it can't reach the data plane
  depends_on = [
    time_sleep.wait_for_firewall_rules,
  ]
}

# Allow all IPs to access Synapse Workspace
resource "azurerm_synapse_firewall_rule" "allow_all" {
  name                 = "allowAll"
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}

# Explicity grant Synapse identity blob contributor permissions for its storage account
resource "azurerm_role_assignment" "synapse_identity_blob_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.synapse_workspace.identity[0].principal_id
}

# And also for Synapse Contributors so they are able to run notebooks that interact with storage
resource "azurerm_role_assignment" "synapse_contributors_blob_contributor" {
  for_each             = toset(var.storage_contributors)
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.key
}

# Grant Synapse's System Assigned Managed Identity read permissions to KeyVault secrets
resource "azurerm_key_vault_access_policy" "synapse" {
  key_vault_id = data.azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_synapse_workspace.synapse_workspace.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
}

# Add wait for firewall rules to be applied (Azure reports done to TF before rules have actually updated)
resource "time_sleep" "wait_for_firewall_rules" {
  depends_on      = [azurerm_synapse_firewall_rule.allow_all]
  create_duration = "120s"
}

resource "local_file" "linkedservice_config" {
  content = templatefile("${path.root}/../synapse/config/linkedservice_config.tpl", {
    keyvault_uri = data.azurerm_key_vault.kv.vault_uri
  })
  filename = "${path.root}/../artifacts/linkedservice_confg.json"
}

# Using Azure CLI here instead of terraform azurerm provider due to lack of support for sovereign clouds
resource "null_resource" "key_vault_linked_service" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
    linkedservice=$(az synapse linked-service show --workspace-name eiad-synapse-${var.random_string} --name keyvault --output tsv --query "name")
    if [ $linkedservice == "keyvault" ]; then
      echo "Removing existing linked service for keyvault"
      az synapse linked-service delete --name keyvault --workspace-name eiad-synapse-${var.random_string} --yes
    fi
    echo "Creating linked service to ${data.azurerm_key_vault.kv.name}"
    az synapse linked-service create --workspace-name eiad-synapse-${var.random_string} --name keyvault --file @"${path.root}/../artifacts/linkedservice_confg.json"
  EOT
  }
  depends_on = [
    azurerm_synapse_workspace.synapse_workspace, local_file.linkedservice_config, time_sleep.wait_for_firewall_rules
  ]
  triggers = {
    always_run = timestamp()
  }
}

# Assign Synapse contributors role permissions within workspace
resource "azurerm_synapse_role_assignment" "synapse_contributors" {
  count                = length(var.synapse_contributors)
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  role_name            = "Synapse Contributor"
  principal_id         = var.synapse_contributors[count.index]
  depends_on = [
    time_sleep.wait_for_firewall_rules,
  ]
}

# Using Azure CLI here instead of terraform azurerm provider due to lack of support for sovereign clouds
# "Synapse Credential Users" role is required to allow execution of pipelines via the REST APIs which is used in our video callback pattern
resource "null_resource" "synapse_credential_user" {
  count = length(var.synapse_credential_users)
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
    roleassignment=$(az synapse role assignment list --workspace-name ${azurerm_synapse_workspace.synapse_workspace.name} --assignee ${var.synapse_credential_users[count.index]} --role "Synapse Credential User" --output tsv --query "[].id")
    if [ -z $roleassignment ]; then
      echo "Creating role assignment to role: Synapse Credential User"
      az synapse role assignment create --workspace-name ${azurerm_synapse_workspace.synapse_workspace.name} --role "Synapse Credential User" --assignee ${var.synapse_credential_users[count.index]}
    fi
  EOT
  }
  depends_on = [
    azurerm_synapse_workspace.synapse_workspace, time_sleep.wait_for_firewall_rules, azurerm_synapse_role_assignment.synapse_contributors
  ]
  triggers = {
    always_run = timestamp()
  }
}

resource "azurerm_synapse_linked_service" "adls_storage" {
  name                 = "adls_storage"
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  type                 = "AzureBlobFS"
  type_properties_json = <<JSON
{
  "url": "${var.primary_dfs_endpoint}"
}
JSON

  depends_on = [
    time_sleep.wait_for_firewall_rules,
  ]
}