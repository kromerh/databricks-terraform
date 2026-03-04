# First, create a resource group to hold everything
resource "azurerm_resource_group" "rg_databricks" {
  name     = "rg-databricks-${var.environment}"
  location = var.location

  tags = {
    Environment = var.environment
    Domain      = "sales"
    ManagedBy   = "terraform"
  }
}

# Then, create the Databricks workspace
resource "azurerm_databricks_workspace" "sales_workspace" {
  name                = "adb-sales-lab-${var.environment}"
  resource_group_name = azurerm_resource_group.rg_databricks.name
  location            = azurerm_resource_group.rg_databricks.location
  sku                 = "premium"

  tags = {
    Environment = var.environment
    Domain      = "sales"
    ManagedBy   = "terraform"
  }
}

# Output the workspace URL so we can access it
output "workspace_url" {
  value = azurerm_databricks_workspace.sales_workspace.workspace_url
}
