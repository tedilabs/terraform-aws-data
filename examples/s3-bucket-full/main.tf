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


  ## Encryption
  encryption = {
    type               = "AWS_KMS"
    kms_key            = "aws/s3"
    bucket_key_enabled = true
  }

  ## Lifecycle
  versioning = {
    status = "ENABLED"
    mfa_deletion = {
      enabled = false
      device  = null
    }
  }
  object_lock = {
    enabled = true
    default_retention = {
      mode  = "GOVERNANCE"
      unit  = "DAYS"
      value = 1
    }
  }
  lifecycle_rules = [
    {
      id      = "expiration-1"
      enabled = false
      prefix  = "hello/"
      noncurrent_version_expiration = {
        days  = 1
        count = 3
      }
    },
    {
      id      = "transitions-1"
      enabled = true
      tags = {
        "Product" = "User"
      }
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "INTELLIGENT_TIERING"
        },
      ]
    }
  ]


  ## Access Control
  policy           = null
  object_ownership = "BucketOwnerEnforced"
  block_public_access = {
    enabled                         = false
    block_public_acls_enabled       = true
    ignore_public_acls_enabled      = true
    block_public_policy_enabled     = true
    restrict_public_buckets_enabled = true
  }
  cors_rules = [
    {
      allowed_methods = ["GET", "POST"]
      allowed_origins = ["*"]
      max_age         = 300
    }
  ]
  tls_required = true


  ## Logging & Metrics
  logging_enabled       = false
  logging_s3_bucket     = null
  logging_s3_key_prefix = null


  ## Misc
  requester_payment_enabled     = true
  transfer_acceleration_enabled = true

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}
