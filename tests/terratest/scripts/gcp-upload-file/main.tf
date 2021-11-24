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

resource "google_storage_bucket_object" "test_file" {
  name   = "test.txt"
  source = "test.txt"
  bucket = "${local.bucket_prefix}-${var.bucket_name}"
}
