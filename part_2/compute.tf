resource "databricks_cluster_policy" "sales" {
  name = "Data Engineering Policy"

  definition = jsonencode({
    "spark_version" : {
      "type" : "regex",
      "pattern" : "1[3-7]\\.[0-9]+\\.x-scala.*",
      "defaultValue" : "17.3.x-scala2.13"
    },
    "node_type_id" : {
      "type" : "allowlist",
      "values" : [
        "Standard_DS3_v2",
        "Standard_DS4_v2",
        "Standard_DS5_v2"
      ],
      "defaultValue" : "Standard_DS3_v2"
    },
    "autoscale.min_workers" : {
      "type" : "fixed",
      "value" : 1
    },
    "autoscale.max_workers" : {
      "type" : "range",
      "minValue" : 1,
      "maxValue" : 10
    },
    "autotermination_minutes" : {
      "type" : "fixed",
      "value" : 60
    },
    "custom_tags.Team" : {
      "type" : "fixed",
      "value" : "data-engineering"
    }
  })
}

resource "databricks_cluster" "shared_engineering" {
  cluster_name            = "shared-engineering"
  spark_version           = "17.3.x-scala2.13"
  node_type_id            = "Standard_DS3_v2"
  autotermination_minutes = 60
  policy_id               = databricks_cluster_policy.sales.id

  autoscale {
    min_workers = 1
    max_workers = 8
  }

  spark_conf = {
    "spark.databricks.io.cache.enabled" = "true"
  }

  custom_tags = {
    "Environment" = var.environment
    "ManagedBy"   = "terraform"
    "Team"        = "data-engineering"
  }
}
