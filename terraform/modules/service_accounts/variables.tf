variable "app_sa_id" {
  description = "Desired account ID for the main application SA."
  default = "226403353486-compute@developer.gserviceaccount.com"
  type        = string
}

variable "dbt_sa_id" {
  description = "Desired account ID for the dbt SA."
  default = "dbt-service-account@int-dev-001.iam.gserviceaccount.com"
  type        = string
}

variable "dataflow_sa_id" {
  description = "Desired account ID for the Dataflow SA."
  default = "llyod-wif@int-dev-001.iam.gserviceaccount.com"
  type        = string
}