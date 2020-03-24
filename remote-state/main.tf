variable "project_name" {} # expected to be passed in via environment variable 'TF_VAR_project_name'
variable "backend_bucket" {} # expected to be passed in via environment variable 'TF_VAR_backend_bucket'

locals {
  region = "northamerica-northeast1"
}

provider "google" {
  credentials = "../credentials.json"
  project     = var.project_name
  region      = local.region
}

resource "google_storage_bucket" "gc_bucket" {
  name     = var.backend_bucket
  location = local.region
}
