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

  ## Lifecycle
  versioning = {
    status = "ENABLED"
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
      id              = "expiration-2"
      enabled         = true
      min_object_size = 300
      max_object_size = 9000
      expiration = {
        days = 7
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
    },
    {
      id      = "transitions-2"
      enabled = true
      noncurrent_version_transitions = [
        {
          days          = 60
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "INTELLIGENT_TIERING"
        },
      ]
    },
    {
      id      = "abort-1"
      enabled = true
      abort_incomplete_multipart_upload = {
        days = 10
      }
    }
  ]


  tags = {
    "project" = "terraform-aws-data-examples"
  }
}
