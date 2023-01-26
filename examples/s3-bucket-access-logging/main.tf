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

module "source_bucket" {
  source = "../../modules/s3-bucket"
  # source  = "tedilabs/data/aws//modules/s3-bucket"
  # version = "~> 0.2.0"

  name          = "${local.bucket_name}-source"
  force_destroy = true

  logging = {
    enabled       = true
    s3_bucket     = module.target_bucket.name
    s3_key_prefix = ""
  }

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}

module "target_bucket" {
  source = "../../modules/s3-bucket"
  # source  = "tedilabs/data/aws//modules/s3-bucket"
  # version = "~> 0.2.0"

  name          = "${local.bucket_name}-target"
  force_destroy = true

  logging = {
    is_target_bucket       = true
    allowed_source_buckets = ["${local.bucket_name}-*"]
  }

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}
