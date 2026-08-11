provider "aws" {
  region = "us-east-1"
}


###################################################
# S3 Table Bucket
###################################################

data "aws_caller_identity" "this" {}

locals {
  bucket_name = "table-bucket-example-${local.account_id}"
  account_id  = data.aws_caller_identity.this.account_id
}

data "aws_iam_policy_document" "table_bucket" {
  statement {
    sid = "AllowReadTablesFromCurrentAccount"

    effect = "Allow"
    actions = [
      "s3tables:GetTable",
      "s3tables:GetTableData",
      "s3tables:GetTableMetadataLocation",
    ]
    resources = [
      "arn:aws:s3tables:us-east-1:${local.account_id}:bucket/${local.bucket_name}/table/*",
    ]

    principals {
      type        = "AWS"
      identifiers = [local.account_id]
    }
  }
}

module "table_bucket" {
  source = "../../modules/s3-table-bucket"
  # source  = "tedilabs/data/aws//modules/s3-table-bucket"
  # version = "~> 0.8.0"

  name          = local.bucket_name
  force_destroy = true

  policy = data.aws_iam_policy_document.table_bucket.json

  maintenance = {
    unreferenced_file_removal = {
      unreferenced_days = 3
      non_current_days  = 10
    }
  }

  namespaces = ["analytics"]

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}


###################################################
# S3 Table
###################################################

## The table ARN contains a table ID which is unknown before creation.
## Use `*` to refer to the table the policy is attached to.
data "aws_iam_policy_document" "table" {
  statement {
    sid = "AllowReadTableFromCurrentAccount"

    effect = "Allow"
    actions = [
      "s3tables:GetTable",
      "s3tables:GetTableData",
      "s3tables:GetTableMetadataLocation",
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [local.account_id]
    }
  }
}

module "table" {
  source = "../../modules/s3-table"
  # source  = "tedilabs/data/aws//modules/s3-table"
  # version = "~> 0.8.0"

  table_bucket = module.table_bucket.arn
  namespace    = module.table_bucket.namespaces["analytics"].name
  name         = "events"

  policy = data.aws_iam_policy_document.table.json

  metadata = {
    schema = [
      {
        name     = "id"
        type     = "long"
        required = true
      },
      {
        name = "type"
        type = "string"
      },
      {
        name = "created_at"
        type = "timestamp"
      },
    ]
  }

  maintenance = {
    snapshot_management = {
      enabled                = true
      max_snapshot_age_hours = 168
      min_snapshots_to_keep  = 2
    }
  }

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}
