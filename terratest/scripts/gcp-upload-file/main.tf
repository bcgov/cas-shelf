terraform {
  required_version = ">= 0.12"
}

provider "google" {
  credentials = file(var.my_credentials_file_path)
  project     = var.project_name
  region      = local.region
}

resource "google_storage_bucket_object" "test_file" {
  name   = "test.txt"
  source = "test.txt"
  bucket = var.bucket_name
}
