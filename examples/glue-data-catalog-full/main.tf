provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}
data "aws_region" "this" {}

locals {
  partition  = data.aws_partition.this.partition
  region     = data.aws_region.this.name
  account_id = data.aws_caller_identity.this.account_id
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "glue:*",
    ]
    resources = [
      "arn:${local.partition}:glue:${local.region}:${local.account_id}:catalog",
      "arn:${local.partition}:glue:${local.region}:${local.account_id}:database/*",
      "arn:${local.partition}:glue:${local.region}:${local.account_id}:table/*/*"
    ]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }

  statement {
    actions = [
      "glue:ShareResource"
    ]
    resources = [
      "arn:${local.partition}:glue:${local.region}:${local.account_id}:catalog",
      "arn:${local.partition}:glue:${local.region}:${local.account_id}:database/*",
      "arn:${local.partition}:glue:${local.region}:${local.account_id}:table/*/*"
    ]
    principals {
      identifiers = ["ram.amazonaws.com"]
      type        = "Service"
    }
  }
}


###################################################
# KMS Keys for Glue
###################################################

module "kms_key" {
  source  = "tedilabs/secret/aws//modules/kms-key"
  version = "~> 0.3.0"

  name        = "example-glue"
  aliases     = ["alias/example-glue"]
  description = "Managed by Terraform."

  usage = "ENCRYPT_DECRYPT"
  spec  = "SYMMETRIC_DEFAULT"

  policy = null

  deletion_window_in_days = 7

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}


###################################################
# Glue Data Catalog
###################################################

module "data_catalog" {
  source = "../../modules/glue-data-catalog"
  # source  = "tedilabs/data/aws//modules/glue-data-catalog"
  # version = "~> 0.2.0"

  policy = data.aws_iam_policy_document.this.json

  encryption_for_connection_passwords = {
    enabled = true
    kms_key = module.kms_key.arn
  }
  encryption_at_rest = {
    enabled = true
    kms_key = module.kms_key.arn
  }

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}
