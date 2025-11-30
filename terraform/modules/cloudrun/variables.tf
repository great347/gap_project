variable "cloud_run_name" {
    default ="llyod-cloud-run"
    type = string
}

variable "cloud_run_image" {
    default = "llyod-image"
    type = string
}

variable "cloud_run_region" {
    default = "us-west1"
    type = string
    }
variable "service_account"{
    default = "226403353486-compute@developer.gserviceaccount.com"
    type = string
}