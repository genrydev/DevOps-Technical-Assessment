terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=3.0.1"
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