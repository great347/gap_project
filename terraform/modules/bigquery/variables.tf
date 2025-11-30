variable "dataset_id" {
  description = "The ID for the new BigQuery dataset."
  default = "dbt_dataset"
  type        = string
}

variable "region" {
  description = "The GCP region for the dataset location."
  default = "us-west1"
  type        = string
}

variable "service_account" {
  description = "The service account email to grant access to the dataset."
  default = "dbt-service-account@int-dev-001.iam.gserviceaccount.com"
  type        = string
}