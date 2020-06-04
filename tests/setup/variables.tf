variable "project_id" {}

variable "credentials" {} # JSON string of the GCP service account credentials file

variable "my_bucket_name" {}

variable "other_bucket_name" {}

locals {
  region  = "northamerica-northeast1" # Montreal
  buckets = list(var.my_bucket_name, var.other_bucket_name)
}
