terraform {
  required_version = "= 1.14.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.59.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.7.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "azuread" {
  client_id     = var.client_id
  tenant_id     = var.tenant_id
  client_secret = var.client_secret
}
