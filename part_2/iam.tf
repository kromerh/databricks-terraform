resource "databricks_group" "sales_data_engineers" {
  provider     = databricks.account
  display_name = "sales-data-engineers"
}

resource "databricks_group" "sales_data_analysts" {
  provider     = databricks.account
  display_name = "sales-data-analysts"
}

resource "databricks_mws_permission_assignment" "sales_data_engineers" {
  provider     = databricks.account
  workspace_id = azurerm_databricks_workspace.sales_workspace.workspace_id
  principal_id = databricks_group.sales_data_engineers.id
  permissions  = ["USER"]
}

resource "databricks_mws_permission_assignment" "sales_data_analysts" {
  provider     = databricks.account
  workspace_id = azurerm_databricks_workspace.sales_workspace.workspace_id
  principal_id = databricks_group.sales_data_analysts.id
  permissions  = ["USER"]
}

resource "databricks_user" "sales_engineers" {
  provider  = databricks.account
  for_each  = toset(var.sales_data_engineers)
  user_name = each.value
}

resource "databricks_group_member" "sales_engineers" {
  provider  = databricks.account
  for_each  = toset(var.sales_data_engineers)
  group_id  = databricks_group.sales_data_engineers.id
  member_id = databricks_user.sales_engineers[each.value].id
}

resource "databricks_user" "sales_analysts" {
  provider  = databricks.account
  for_each  = toset(var.sales_data_analysts)
  user_name = each.value
}

resource "databricks_group_member" "sales_analysts" {
  provider  = databricks.account
  for_each  = toset(var.sales_data_analysts)
  group_id  = databricks_group.sales_data_analysts.id
  member_id = databricks_user.sales_analysts[each.value].id
}

resource "databricks_grants" "sales_analytics_catalog" {
  catalog = databricks_catalog.sales_analytics.name

  grant {
    principal  = databricks_group.sales_data_engineers.display_name
    privileges = ["USE_CATALOG", "USE_SCHEMA", "CREATE_TABLE", "SELECT", "MODIFY"]
  }

  grant {
    principal  = databricks_group.sales_data_analysts.display_name
    privileges = ["USE_CATALOG", "USE_SCHEMA", "SELECT"]
  }
}

resource "databricks_permissions" "sales_shared_cluster" {
  cluster_id = databricks_cluster.shared_engineering.id

  access_control {
    group_name       = databricks_group.sales_data_engineers.display_name
    permission_level = "CAN_RESTART"
  }

  access_control {
    group_name       = databricks_group.sales_data_analysts.display_name
    permission_level = "CAN_ATTACH_TO"
  }

  depends_on = [
    databricks_mws_permission_assignment.sales_data_analysts,
    databricks_mws_permission_assignment.sales_data_engineers
  ]
}
