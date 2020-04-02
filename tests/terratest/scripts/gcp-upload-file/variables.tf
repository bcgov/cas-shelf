locals {
  region        = "northamerica-northeast1" # Montreal
  bucket_prefix = file("../../../test-bucket-prefix")
}

variable "project_name" {}

variable "bucket_name" {}

variable "my_credentials_file_path" {}
