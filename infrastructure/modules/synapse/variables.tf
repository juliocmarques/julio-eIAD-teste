variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "random_string" {
  type = string
}

variable "key_vault_name" {
  type = string
}

variable "storage_account_id" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "adls_filesystem_id" {
  type = string
}

variable "synapse_contributors" {
  type        = list(string)
  description = "List of Object IDs of AAD principals / groups to be given contribute access to Synapse"
}

variable "synapse_credential_users" {
  type        = list(string)
  description = "List of Object IDs of AAD principals / groups to be given credential user access to the RG"
  default     = []
}

variable "node_count" {
  type        = number
  description = "Number of nodes to allocate to the spark pool"
}

variable "storage_contributors" {
  type        = list(string)
  description = "List of Object IDs of AAD principals / groups to be given contribute access to the storage account"
}

variable "tags" {
}

variable "azure_monitor_workspace_id" {
  type        = string
  description = "Azure Monitor Workspace Id"
}

variable "primary_dfs_endpoint" {
  type = string
}

variable "storage_sas_token" {
  type = string
}