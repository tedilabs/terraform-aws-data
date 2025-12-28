data "aws_caller_identity" "this" {}
data "aws_region" "this" {
  region = var.region
}

locals {
  account_id = data.aws_caller_identity.this.account_id
  region     = data.aws_region.this.region
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
