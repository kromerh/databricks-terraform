terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.62.1"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.110.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  host = azurerm_databricks_workspace.sales_workspace.workspace_url
}
