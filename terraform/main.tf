terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    bucket = "llyod_bucket124" # Replace with your GCS bucket name
    prefix = "terraform/state" # Optional: Organize state files within the bucket
  }
}


# Configure the Google Provider using variables from variables.tf
provider "google" {
  project = var.project_id
  region  = var.region
}


# Enable necessary APIs
resource "google_project_service" "gcp_services" {
  for_each = toset([
    "bigquery.googleapis.com",
    "storage.googleapis.com"
  ])
  service            = each.key
  disable_on_destroy = false
}

# google Cloud Storage Bucket
resource "google_storage_bucket" "data_bucket" {
  name          = "llyod_bucket124" # Must be globally unique
  location      = var.region
  force_destroy = true
  depends_on    = [google_project_service.gcp_services]
  versioning {
    enabled = true
  }
}

# create bigquery resource
resource "google_bigquery_dataset" "raw_data_dataset" {
  dataset_id = "dbt_dataset_new"
  location   = var.region
  depends_on = [google_project_service.gcp_services]
}



