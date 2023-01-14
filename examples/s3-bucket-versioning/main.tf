provider "aws" {
  region = "us-east-1"
}


###################################################
# S3 Bucket
###################################################

resource "random_string" "this" {
  length  = 32
  special = false
  numeric = false
  upper   = false
}

locals {
  bucket_name = random_string.this.id
}

module "bucket" {
  source = "../../modules/s3-bucket"
  # source  = "tedilabs/data/aws//modules/s3-bucket"
  # version = "~> 0.2.0"

  name          = local.bucket_name
  force_destroy = true

  versioning = {
    status = "ENABLED"
    mfa_deletion = {
      enabled = false
      device  = null
    }
  }

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}
