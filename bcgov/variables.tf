# Since variables could be overridden via environment variables, use local values to define immutable values
locals {
  # The GCP region to create things in. https://cloud.google.com/compute/docs/regions-zones"
  region = "northamerica-northeast1" # Montreal
}

variable "credentials" {
  description = "The service account private key of the GCP project as json string"
}

variable "project_name" {
  description = "The ID of the GCP project"
}

variable "kubernetes_host" {
  description = "The hostname of the OCP cluster"
}

variable "kubernetes_token" {
  description = "The authentication token of the OCP cluster"
}

variable "slug" {
  type        = list(string)
  description = "The slug for the OCP cluster"
}

variable "application" {
  type        = list(string)
  description = "The list of application names of the OCP project"
}

variable "envs" {
  type        = list(string)
  description = "The environment names of the OCP cluster"
  default     = ["dev", "test", "prod", "tools"]
}
