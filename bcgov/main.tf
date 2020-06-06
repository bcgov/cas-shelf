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
  for_each = { for v in var.namespace_apps : v => "${split(",", v)[0]}-${split(",", v)[1]}" }
  name     = each.value
  location = local.region
}

# Create GCP service accounts for each GCS bucket
resource "google_service_account" "account" {
  for_each     = { for v in var.namespace_apps : v => "${split(",", v)[0]}-${split(",", v)[1]}" }
  account_id   = "${each.value}-sa"
  display_name = "${each.value} Service Account"
  depends_on   = [google_storage_bucket.bucket]
}

# # Assign Storage Admin role for the corresponding service accounts
resource "google_storage_bucket_iam_member" "admin" {
  for_each   = { for v in var.namespace_apps : v => "${split(",", v)[0]}-${split(",", v)[1]}" }
  bucket     = each.value
  role       = "roles/storage.admin"
  member     = "serviceAccount:${google_service_account.account[each.key].email}"
  depends_on = [google_service_account.account]
}

# Create keys for the service accounts
resource "google_service_account_key" "key" {
  for_each           = { for v in var.namespace_apps : v => "${split(",", v)[0]}-${split(",", v)[1]}" }
  service_account_id = google_service_account.account[each.key].name
}

resource "kubernetes_secret" "secret_sa" {
  for_each = { for v in var.namespace_apps : v => "${split(",", v)[0]}-${split(",", v)[1]}" }
  metadata {
    name      = "gcp-${each.value}-service-account-key"
    namespace = split(",", each.key)[0]
    labels = {
      created-by = "Terraform"
    }
  }

  data = {
    "bucket_name"      = each.value
    "credentials.json" = base64decode(google_service_account_key.key[each.key].private_key)
  }
}

resource "kubernetes_secret" "secret_tfc" {
  for_each = { for v in var.kubernetes_namespaces : v => v }
  metadata {
    name      = "terraform-cloud-workspace"
    namespace = each.key
    labels = {
      created-by = "Terraform"
    }
  }

  data = {
    "token"        = var.terraform_cloud_token
    "workspace_id" = var.terraform_cloud_workspace_id
  }
}
