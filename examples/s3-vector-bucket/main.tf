provider "aws" {
  region = "us-east-1"
}


###################################################
# S3 Vector Bucket
###################################################

data "aws_caller_identity" "this" {}

locals {
  bucket_name = "vector-bucket-example-${local.account_id}"
  account_id  = data.aws_caller_identity.this.account_id
}

data "aws_iam_policy_document" "this" {
  statement {
    sid = "AllowQueryVectorsFromCurrentAccount"

    effect = "Allow"
    actions = [
      "s3vectors:GetVectors",
      "s3vectors:QueryVectors",
    ]
    resources = [
      "arn:aws:s3vectors:us-east-1:${local.account_id}:bucket/${local.bucket_name}/index/*",
    ]

    principals {
      type        = "AWS"
      identifiers = [local.account_id]
    }
  }
}

module "vector_bucket" {
  source = "../../modules/s3-vector-bucket"
  # source  = "tedilabs/data/aws//modules/s3-vector-bucket"
  # version = "~> 0.8.0"

  name          = local.bucket_name
  force_destroy = true

  policy = data.aws_iam_policy_document.this.json

  indexes = [
    {
      name      = "documents"
      dimension = 1024

      metadata = {
        non_filterable_keys = ["chunk"]
      }
    },
    {
      name            = "images"
      dimension       = 512
      distance_metric = "euclidean"

      tags = {
        "purpose" = "image-search"
      }
    },
  ]

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}
