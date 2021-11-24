terraform {
  required_version = ">= 0.12"
  required_providers {
    google = {
      version = "= 3.65.0"
    }
  }
}

provider "google" {
  credentials = file(var.my_credentials_file_path)
  project     = var.project_id
  region      = local.region
}

resource "random_string" "bucket_prefix" {
  length           = 12
  special          = false
  upper            = false
  number           = false
  override_special = "/@£$"
}

resource "google_storage_bucket" "new_bucket" {
  name     = "${random_string.bucket_prefix.result}-bucket-for-terratest"
  location = local.region
}
