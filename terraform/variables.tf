variable "project_id" {
  description = "The GCP project ID"
  default     = "int-dev-001" # CHANGE THIS
}

variable "region" {
  description = "The GCP region to deploy resources"
  default     = "us-central1" # CHANGE THIS
}

variable "service_account_email" {
  description = "Email of the user/SA to grant access to BQ and GCS"
  # CHANGE THIS to your existing user or service account email
  default     = "terrafrom-user@int-dev-001.iam.gserviceaccount.com" 
}