variable "resource_group_name" {
  type    = string
  default = "eiad"
}

variable "location" {
  type = string
}

variable "resource_group_contributors" {
  type        = list(string)
  description = "List of Object IDs of AAD principals / groups to be given contribute access to the RG"
  default     = []
}

variable "azuread_object_owners" {
  type        = list(string)
  description = "List of Object IDs or AAD Users to be made owners of Azure AD objects created for eIAD"
  default     = []
}

variable "tags" {
  default = {
    "ProjectName" = "eIAD"
  }
}

variable "is_local" {
  type    = bool
  default = false
}

variable "build_number" {
  type        = string
  default     = "local"
  description = "Build Number from Azure DevOps"
}

variable "node_count" {
  type        = number
  default     = 14
  description = "Number of nodes to allocate to the spark pool"
}