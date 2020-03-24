# Since variables could be overridden via environment variables, use local values to define immutable values
locals {
  # The GCP region to create things in. https://cloud.google.com/compute/docs/regions-zones"
  region = "northamerica-northeast1" # Montreal
}

variable "project_name" {
  description = "The ID of the Google Cloud project"
  default     = "project-name"
}

variable "credentials_file_path" {
  description = "Path to the JSON file used to describe your account credentials"
  default     = "./credentials.json"
}

variable "envs" {
  type        = list(string)
  description = "Application environments to create"
  default     = ["dev", "test", "prod", "tools"]
}

variable "namespace" {
  description = "Namespace for the GCS Bucket"
  default     = "namespace"
}

variable "application" {
  description = "Application name for the GCS Bucket"
  default     = "application"
}
