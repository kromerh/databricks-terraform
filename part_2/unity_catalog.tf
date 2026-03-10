resource "databricks_metastore_assignment" "sales_workspace" {
  provider     = databricks.account
  metastore_id = var.databricks_metastore_id
  workspace_id = azurerm_databricks_workspace.sales_workspace.workspace_id
}

resource "azurerm_storage_account" "lab" {
  name                     = "stadblab${var.environment}"
  resource_group_name      = azurerm_resource_group.rg_databricks.name
  location                 = azurerm_resource_group.rg_databricks.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "azurerm_storage_container" "main" {
  name                  = "main"
  storage_account_id    = azurerm_storage_account.lab.id
  container_access_type = "private"
}

resource "azurerm_databricks_access_connector" "uc" {
  name                = "dac-unity-${var.environment}"
  resource_group_name = azurerm_resource_group.rg_databricks.name
  location            = azurerm_resource_group.rg_databricks.location

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "azurerm_role_assignment" "uc_storage" {
  scope                = azurerm_storage_account.lab.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.uc.identity[0].principal_id
}

resource "databricks_storage_credential" "external" {
  name = "uuc-credential-${var.environment}"

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.uc.id
  }

  comment    = "Managed by Terraform"
  depends_on = [databricks_metastore_assignment.sales_workspace]
}

resource "databricks_external_location" "data" {
  name = "lab_data-${var.environment}"
  url = format("abfss://%s@%s.dfs.core.windows.net/",
    azurerm_storage_container.main.name,
    azurerm_storage_account.lab.name
  )

  credential_name = databricks_storage_credential.external.name
  comment         = "Managed by Terraform"
  depends_on      = [azurerm_role_assignment.uc_storage]
}

resource "databricks_catalog" "sales_analytics" {
  name    = "sales_analytics_${var.environment}"
  comment = "Sales analytics catalog for ${var.environment} environment. Managed by Terraform."

  depends_on = [databricks_external_location.data]
}

resource "databricks_schema" "bronze" {
  catalog_name = databricks_catalog.sales_analytics.name
  name         = "bronze"
  comment      = "Raw ingested data. Managed by Terraform."
}

resource "databricks_schema" "silver" {
  catalog_name = databricks_catalog.sales_analytics.name
  name         = "silver"
  comment      = "Cleaned and transformed data. Managed by Terraform."
}
