terraform {
  required_version = ">= 0.12"
}

provider "google" {
  credentials = var.credentials
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

resource "google_storage_bucket" "bucket" {
  count    = length(local.buckets)
  name     = "${random_string.bucket_prefix.result}-${element(local.buckets, count.index)}"
  location = local.region
}

resource "google_service_account" "account" {
  count        = length(local.buckets)
  account_id   = "${google_storage_bucket.bucket[count.index].name}-sa"
  display_name = "${google_storage_bucket.bucket[count.index].name} Service Account"
  depends_on   = [google_storage_bucket.bucket]
}

resource "google_storage_bucket_iam_member" "editor" {
  count      = length(local.buckets)
  bucket     = google_storage_bucket.bucket[count.index].name
  role       = "roles/storage.admin"
  member     = "serviceAccount:${google_service_account.account[count.index].email}"
  depends_on = [google_service_account.account]
}

resource "google_service_account_key" "key" {
  count              = length(local.buckets)
  service_account_id = google_service_account.account[count.index].name
}

data "google_service_account_key" "key" {
  count = length(local.buckets)
  name  = google_service_account_key.key[count.index].name
}

resource "local_file" "file" {
  count    = length(local.buckets)
  filename = "./keys/${element(local.buckets, count.index)}.json"
  content  = base64decode(google_service_account_key.key[count.index].private_key)
}

resource "local_file" "bucket_prefix" {
  filename = "./test-bucket-prefix"
  content  = random_string.bucket_prefix.result
}
