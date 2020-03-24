variable "project_name" {}

variable "my_bucket_name" {}

variable "other_bucket_name" {}

variable "credentials_file_path" {}

locals {
  region = "northamerica-northeast1" # Montreal
  buckets = list(var.my_bucket_name,var.other_bucket_name)
}
