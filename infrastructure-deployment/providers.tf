terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    azapi = {
      source = "azure/azapi"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rgtfstate"
    storage_account_name = "rgtfstateemzxfuig"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {
}
