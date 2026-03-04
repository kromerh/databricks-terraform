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
