terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.83.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
  }
}

provider "azurerm" {
  # Configuration options
    features {}
    
    subscription_id   = var.subscription_id
    tenant_id         = var.tenant_id
    client_id         = var.client_id
    client_secret     = var.client_secret
}
