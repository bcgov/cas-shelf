terraform {
  required_version = ">= 0.12"
}

provider "google" {
  credentials = file(var.my_credentials_file_path)
  project     = var.project_name
  region      = local.region
}

resource "random_string" "new_bucket_prefix" {
  length = 12
  special = false
  upper = false
  override_special = "/@£$"
}

resource "google_storage_bucket" "new_bucket" {
  name     = "${random_string.new_bucket_prefix.result}-bucket-for-terratest"
  location = local.region
}