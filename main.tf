# Configure GCS backend to store the state as an object
terraform {
  backend "gcs" {
    prefix      = "terraform/state"
  }
}

# Configure GCP infrastructure to setup the credentials, default project and location (zone and/or region) for your resources
provider "google" {
  credentials = file(var.credentials_file_path)
  project     = var.project_name
  region      = local.region
}

# Create GCS buckets
resource "google_storage_bucket" "gc_bucket" {
  count    = length(var.envs)
  name     = "${var.namespace}-${element(var.envs, count.index)}-${var.application}"
  location = local.region
}

# Create GCP service accounts for each GCS bucket
resource "google_service_account" "gc_account" {
  count        = length(var.envs)
  account_id   = "${var.namespace}-${element(var.envs, count.index)}-${var.application}-sa"
  display_name = "${var.namespace}-${element(var.envs, count.index)}-${var.application} Service Account"
  depends_on   = [google_storage_bucket.gc_bucket]
}

# Assign Storage Admin role for the corresponding service accounts
resource "google_storage_bucket_iam_member" "gc_editor" {
  count      = length(var.envs)
  bucket     = "${var.namespace}-${element(var.envs, count.index)}-${var.application}"
  role       = "roles/storage.admin"
  member     = "serviceAccount:${var.namespace}-${element(var.envs, count.index)}-${var.application}-sa@${var.project_name}.iam.gserviceaccount.com"
  depends_on = [google_service_account.gc_account]
}

# Create keys for the service accounts
resource "google_service_account_key" "gc_key" {
  count              = length(var.envs)
  service_account_id = google_service_account.gc_account[count.index].name
}

# Export the service account keys in '.key' file, which is a PEM formatted file containing
# just the private-key of a specific certificate
data "google_service_account_key" "gc_key" {
  count            = length(var.envs)
  name             = google_service_account_key.gc_key[count.index].name
}

# Save the service account key files in a local directory 'keys'
resource "local_file" "gc_file" {
  count    = length(var.envs)
  filename = "./keys/${var.namespace}-${element(var.envs, count.index)}-${var.application}.json"
  content  = base64decode(google_service_account_key.gc_key[count.index].private_key)
}
