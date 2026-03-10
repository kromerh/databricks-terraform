variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure cloud region"
  type        = string
  default     = "switzerlandnorth"
}

variable "databricks_account_id" {
  description = "Databricks account ID (found in Databricks account console)"
  type        = string
}

variable "databricks_metastore_id" {
  description = "ID of the existing Unity Catalog metastore to assign to this workspace"
  type        = string
}

variable "sales_data_engineers" {
  description = "List of data engineer email addresses"
  type        = list(string)
  default     = []
}

variable "sales_data_analysts" {
  description = "List of data analyst email addresses"
  type        = list(string)
  default     = []
}
