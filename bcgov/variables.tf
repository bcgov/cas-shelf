# Since variables could be overridden via environment variables, use local values to define immutable values
locals {
  # The GCP region to create things in. https://cloud.google.com/compute/docs/regions-zones"
  region = "northamerica-northeast1" # Montreal
}

variable "project_id" {
  description = "The ID of the GCP project"
}

variable "credentials_private_key" {
  description = "The private_key of GCP service account credentials key"
}

variable "credentials_client_email" {
  description = "The client_email of GCP service account credentials key"
}

variable "kubernetes_host" {
  description = "The hostname of the OCP cluster"
}

variable "kubernetes_token" {
  description = "The authentication token of the OCP cluster"
}

variable "kubernetes_namespaces" {
  type        = list(string)
  description = "The OCP namespaces to run jobs"
}

variable "terraform_cloud_token" {
  description = "The user/team token of Terraform Cloud"
}

variable "terraform_cloud_workspace_id" {
  description = "The workspace id of Terraform Cloud"
}

variable "namespace_apps" {
  type        = list(string)
  description = "The list of namespace and app name pairs of the OCP project"
}
