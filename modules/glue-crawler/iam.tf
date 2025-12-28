data "aws_caller_identity" "this" {}
data "aws_region" "this" {
  region = var.region
}

locals {
  account_id = data.aws_caller_identity.this.account_id
  region     = data.aws_region.this.region

  s3_source_buckets = [
    for source in var.s3_data_sources : {
      name       = regex("s3://([^/]+)(?:/(.+?))?/?$", source.path)[0]
      key_prefix = trim(trimprefix(source.path, "s3://${regex("s3://([^/]+)(?:/(.+?))?/?$", source.path)[0]}"), "/")
    }
  ]
}


###################################################
# IAM Role for Glue Crawler
###################################################

module "role" {
  count = var.default_service_role.enabled ? 1 : 0

  source  = "tedilabs/account/aws//modules/iam-role"
  version = "~> 0.33.0"

  name = coalesce(
    var.default_service_role.name,
    "glue-crawler-${local.metadata.name}",
  )
  path        = var.default_service_role.path
  description = var.default_service_role.description

  trusted_service_policies = [
    {
      services = ["glue.amazonaws.com"]
    },
  ]

  policies = concat(
    ["arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"],
    var.default_service_role.policies,
  )
  inline_policies = merge(
    {
      "cloudwatch" = data.aws_iam_policy_document.cloudwatch.json
      "glue"       = data.aws_iam_policy_document.glue.json
      "s3-sources" = data.aws_iam_policy_document.s3_sources.json
    },
    var.default_service_role.inline_policies
  )

  force_detach_policies = true
  resource_group = {
    enabled = false
  }
  module_tags_enabled = false

  tags = merge(
    local.module_tags,
    var.tags,
  )
}


###################################################
# IAM Policies
###################################################

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
    ]
    resources = [
      provider::aws::arn_build("aws", "logs", local.region, local.account_id, "log-group/aws-glue/crawlers"),
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
    ]
    resources = [
      provider::aws::arn_build("aws", "logs", local.region, local.account_id, "log-group/aws-glue/crawlers:log-stream:${var.name}"),
    ]
  }
}

data "aws_iam_policy_document" "glue" {
  statement {
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:UpdateDatabase",
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:GetTable",
      "glue:GetTables",
      "glue:BatchCreatePartition",
      "glue:CreatePartition",
      "glue:DeletePartition",
      "glue:BatchDeletePartition",
      "glue:UpdatePartition",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition",
      "glue:ImportCatalogToGlue",
    ]
    resources = [
      provider::aws::arn_build("aws", "glue", local.region, local.account_id, "catalog"),
      provider::aws::arn_build("aws", "glue", local.region, local.account_id, "database/${var.destination.database}"),
      provider::aws::arn_build("aws", "glue", local.region, local.account_id, "table/${var.destination.database}/${var.destination.table_prefix}*"),
    ]
  }
}

data "aws_iam_policy_document" "s3_sources" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      for bucket in local.s3_source_buckets :
      provider::aws::arn_build("aws", "s3", "", "", bucket.name)
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      for bucket in local.s3_source_buckets :
      (length(bucket.key_prefix) > 0
        ? provider::aws::arn_build("aws", "s3", "", "", "${bucket.name}/${bucket.key_prefix}/*")
        : provider::aws::arn_build("aws", "s3", "", "", "${bucket.name}/*")
      )
    ]
  }
}
