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

variable "slug" {
  description = "The slug for the OCP cluster"
}

variable "apps" {
  type        = list(string)
  description = "The list of application names of the OCP project"
}

variable "envs" {
  type        = list(string)
  description = "The environment names of the OCP cluster"
  default     = ["dev", "test", "prod", "tools"]
}
