terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.26.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.29.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.3"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }
  }
}

provider "azurerm" {
  features {}
}