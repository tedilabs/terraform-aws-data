provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

resource "random_string" "this" {
  length  = 32
  special = false
  numeric = false
  upper   = false
}

locals {
  bucket_name       = random_string.this.id
  access_point_name = "access-point-test-internet"

  account_id = data.aws_caller_identity.this.account_id
  region     = data.aws_region.this.name
}


###################################################
# S3 Bucket
###################################################

module "bucket" {
  source = "../../modules/s3-bucket"
  # source  = "tedilabs/data/aws//modules/s3-bucket"
  # version = "~> 0.2.0"

  name          = local.bucket_name
  force_destroy = true

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}


###################################################
# S3 Access Point
###################################################

module "access_point" {
  source = "../../modules/s3-access-point"
  # source  = "tedilabs/data/aws//modules/s3-access-point"
  # version = "~> 0.2.0"

  name = local.access_point_name
  bucket = {
    name = module.bucket.name
  }

  policy = null
  block_public_access = {
    enabled = true
  }
}
