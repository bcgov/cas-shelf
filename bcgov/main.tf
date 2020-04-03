# Configure OCP infrastructure to setup the host and authentication token
provider "kubernetes" {
  load_config_file = "false"
  host             = var.kubernetes_host
  token            = var.kubernetes_token
}

# Configure GCP infrastructure to setup the credentials, default project and location (zone and/or region) for your resources
provider "google" {
  credentials = var.credentials
  project     = var.project_name
  region      = local.region
}

# Create GCS buckets
resource "google_storage_bucket" "gc_bucket" {
  count    = length(var.application) * length(var.envs)
  name     = "${var.slug}-${element(var.envs, count.index % length(var.envs))}-${element(var.application, floor(count.index / length(var.envs)))}"
  location = local.region
}

# Create GCP service accounts for each GCS bucket
resource "google_service_account" "gc_account" {
  count        = length(google_storage_bucket.gc_bucket)
  account_id   = "${google_storage_bucket.gc_bucket[count.index].name}-sa"
  display_name = "${google_storage_bucket.gc_bucket[count.index].name} Service Account"
  depends_on   = [google_storage_bucket.gc_bucket]
}

# Assign Storage Admin role for the corresponding service accounts
resource "google_storage_bucket_iam_member" "gc_editor" {
  count      = length(google_storage_bucket.gc_bucket)
  bucket     = google_storage_bucket.gc_bucket[count.index].name
  role       = "roles/storage.admin"
  member     = "serviceAccount:${google_service_account.gc_account[count.index].email}"
  depends_on = [google_service_account.gc_account]
}

# Create keys for the service accounts
resource "google_service_account_key" "gc_key" {
  count              = length(google_storage_bucket.gc_bucket)
  service_account_id = google_service_account.gc_account[count.index].name
}

# https://docs.openshift.com/container-platform/3.7/dev_guide/secrets.html#types-of-secrets
resource "kubernetes_secret" "secret_object" {
  count = length(google_storage_bucket.gc_bucket)
  metadata {
    name      = "gcp-${google_storage_bucket.gc_bucket[count.index].name}-service-account-key"
    namespace = "${var.slug}-${element(var.envs, count.index % length(var.envs))}"
  }

  data = {
    "bucket-name"      = google_storage_bucket.gc_bucket[count.index].name
    "credentials.json" = base64decode(google_service_account_key.gc_key[count.index].private_key)
  }
}
