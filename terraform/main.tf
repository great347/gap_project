terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

variable "project_id" { 
  default = "int-dev-001"
  type = string
 }
variable "region" { 
  default = "us-west1"
  type = string
}

variable "vpc_name" {
     default = "main-vpc" 
     type = string
}

variable "subnet_cidr" { 
    default = "10.10.0.0/24" 
    type = string
}

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
variable "bucket_name" {
    default = "llyod_bucket1234"
    type = string
}

variable "dataset_id" {
    default = "dbt_dataset"
    type = string
}

variable "wif_pool_id" {
    default ="llyod action pool"
    type = string
}

variable "wif_provider_id" {
    default = "llyod-github"
    type = string
}

variable "wif_oidc_issuer" {
    default = "https://token.actions.githubusercontent.com"
    type = string
}
variable "cloud_run_name" {
    default ="llyod-cloud-run"
    type = string
}

variable "cloud_run_image" {
    default = "llyod-image"
    type = string
}



provider "google" {
  project = var.project_id
  region  = var.region
}

# --- Module Calls (Corrected Syntax) ---

module "network" {
  source      = "./modules/network"
  vpc_name    = var.vpc_name        # Use var.vpc_name (input)
  subnet_cidr = var.subnet_cidr     # Use var.subnet_cidr (input)
  project_id  = var.project_id      # Pass the root project ID
}

module "service_accounts" {
  source = "./modules/service_accounts"
  app_sa_id      = var.app_sa_id      # Use var.app_sa_id (input)
  dbt_sa_id      = var.dbt_sa_id      # Use var.dbt_sa_id (input)
  dataflow_sa_id = var.dataflow_sa_id # Use var.dataflow_sa_id (input)
}

module "storage" {
  source       = "./modules/storage"
  bucket_name  = var.bucket_name                     # Use var.bucket_name (input)
  region       = var.region                          # Use var.region (input)
  service_account = module.service_accounts.app_sa_email # Use output from service_accounts module
}

module "bigquery" {
  source       = "./modules/bigquery"
  dataset_id   = var.dataset_id                    # Use var.bq_dataset (input)
  region       = var.region                          # Use var.region (input)
  service_account = module.service_accounts.app_sa_email # Use output from service_accounts module
}

module "dataflow" {
  source          = "./modules/dataflow"
  project_id      = var.project_id                           # Use var.project_id (input)
  region          = var.region                               # Use var.region (input)
  service_account = module.service_accounts.dataflow_sa_email  # Use output from service_accounts module
  bucket_name     = var.bucket_name                            # Use var.bucket_name (input)
}

module "cloudrun" {
  source           = "./modules/cloudrun"
  cloud_run_name   = var.cloud_run_name   # Use var.cloud_run_name (input)
  cloud_run_image  = var.cloud_run_image  # Use var.cloud_run_image (input)
  service_account  = module.service_accounts.app_sa_email # Use output from service_accounts module
}

module "wif" {
  source           = "./modules/wif"
  wif_pool_id      = var.wif_pool_id      # Use var.wif_pool_id (input)
  wif_provider_id  = var.wif_provider_id  # Use var.wif_provider_id (input)
  wif_oidc_issuer  = var.wif_oidc_issuer  # Use var.wif_oidc_issuer (input)

}

