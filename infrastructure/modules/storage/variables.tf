variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "random_string" {
  type = string
}

variable "storage_containers" {
  type    = list(string)
  default = []
}

variable "adls_filesystems" {
  type    = list(string)
  default = []
}

variable "tags" {}

variable "storage_name_prefix" {
  type = string
}

variable "is_hns_enabled" {
}

variable "replication_type" {
  type = string
}
