terraform {
  required_version = ">= 0.12"
}

provider "google" {
  credentials = file(var.credentials_file_path)
  project     = var.project_name
  region      = local.region
}

resource "google_storage_bucket" "gc_bucket" {
  count    = length(local.buckets)
  name     = element(local.buckets, count.index)
  location = local.region
}

resource "google_service_account" "gc_account" {
  count        = length(local.buckets)
  account_id   = "${element(local.buckets, count.index)}-sa"
  display_name = "${element(local.buckets, count.index)} Service Account"
  depends_on   = [google_storage_bucket.gc_bucket]
}

resource "google_storage_bucket_iam_member" "gc_editor" {
  count      = length(local.buckets)
  bucket     = element(local.buckets, count.index)
  role       = "roles/storage.admin"
  member     = "serviceAccount:${element(local.buckets, count.index)}-sa@${var.project_name}.iam.gserviceaccount.com"
  depends_on = [google_service_account.gc_account]
}

resource "google_service_account_key" "gc_key" {
  count              = length(local.buckets)
  service_account_id = google_service_account.gc_account[count.index].name
}

data "google_service_account_key" "gc_key" {
  count            = length(local.buckets)
  name             = google_service_account_key.gc_key[count.index].name
}

resource "local_file" "gc_file" {
  count    = length(local.buckets)
  filename = "./keys/${element(local.buckets, count.index)}.json"
  content  = base64decode(google_service_account_key.gc_key[count.index].private_key)
}
