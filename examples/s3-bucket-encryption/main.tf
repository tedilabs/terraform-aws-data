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
  bucket_name  = random_string.this.id
  kms_key_name = random_string.this.id
}

module "bucket" {
  source = "../../modules/s3-bucket"
  # source  = "tedilabs/data/aws//modules/s3-bucket"
  # version = "~> 0.2.0"

  name          = "${local.bucket_name}-aes256"
  force_destroy = true

  encryption = {
    type               = "AES256"
    bucket_key_enabled = true
  }

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}

module "bucket_kms" {
  source = "../../modules/s3-bucket"
  # source  = "tedilabs/data/aws//modules/s3-bucket"
  # version = "~> 0.2.0"

  name          = "${local.bucket_name}-aws-kms"
  force_destroy = true

  encryption = {
    type               = "AWS_KMS"
    kms_key            = module.kms_key.id
    bucket_key_enabled = true
  }

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}

module "kms_key" {
  source  = "tedilabs/secret/aws//modules/kms-key"
  version = "~> 0.3.0"

  name = local.kms_key_name

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}
