# Configure OCP infrastructure to setup the host and authentication token
provider "kubernetes" {
  load_config_file = "false"
  host             = var.kubernetes_host
  token            = var.kubernetes_token
}

data "template_file" "credentials" {
  template = <<EOF
{
  "type":"service_account",
  "project_id":"${var.project_id}",
  "private_key":"${replace(var.credentials_private_key, "\n", "\\n")}",
  "client_email":"${var.credentials_client_email}"
}
EOF
}

# Configure GCP infrastructure to setup the credentials, default project and location (zone and/or region) for your resources
provider "google" {
  credentials = data.template_file.credentials.rendered
  project     = var.project_id
  region      = local.region
}

# Create GCS buckets
resource "google_storage_bucket" "bucket" {
  count    = length(var.namespace_apps)
  name     = "${split(",", element(var.namespace_apps, count.index))[0]}-${split(",", element(var.namespace_apps, count.index))[1]}"
  location = local.region
}

# Create GCP service accounts for each GCS bucket
resource "google_service_account" "account" {
  count        = length(google_storage_bucket.bucket)
  account_id   = "${google_storage_bucket.bucket[count.index].name}-sa"
  display_name = "${google_storage_bucket.bucket[count.index].name} Service Account"
  depends_on   = [google_storage_bucket.bucket]
}

# Assign Storage Admin role for the corresponding service accounts
resource "google_storage_bucket_iam_member" "editor" {
  count      = length(google_storage_bucket.bucket)
  bucket     = google_storage_bucket.bucket[count.index].name
  role       = "roles/storage.admin"
  member     = "serviceAccount:${google_service_account.account[count.index].email}"
  depends_on = [google_service_account.account]
}

# Create keys for the service accounts
resource "google_service_account_key" "key" {
  count              = length(google_storage_bucket.bucket)
  service_account_id = google_service_account.account[count.index].name
}

# https://docs.openshift.com/container-platform/3.7/dev_guide/secrets.html#types-of-secrets
resource "kubernetes_secret" "secret_sa" {
  count = length(google_storage_bucket.bucket)
  metadata {
    name      = "gcp-${google_storage_bucket.bucket[count.index].name}-service-account-key"
    namespace = split(",", element(var.namespace_apps, count.index))[0]
  }

  data = {
    "bucket_name"      = google_storage_bucket.bucket[count.index].name
    "credentials.json" = base64decode(google_service_account_key.key[count.index].private_key)
  }
}

resource "kubernetes_secret" "secret_tfc" {
  count = length(var.kubernetes_namespaces)
  metadata {
    name      = "terraform-cloud-workspace"
    namespace = element(var.kubernetes_namespaces, count.index)
  }

  data = {
    "token"        = var.terraform_cloud_token
    "workspace_id" = var.terraform_cloud_workspace_id
  }
}
