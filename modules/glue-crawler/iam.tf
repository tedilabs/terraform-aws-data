data "aws_iam_role" "custom" {
  count = var.custom_iam_role != null ? 1 : 0

  name = (startswith(var.custom_iam_role, "arn:aws")
    ? split(":role/", var.custom_iam_role)[1]
    : var.custom_iam_role
  )
}


###################################################
# IAM Role for Glue Crawler
###################################################

module "role" {
  count = (var.custom_iam_role == null && var.iam_role.enabled) ? 1 : 0

  source  = "tedilabs/account/aws//modules/iam-role"
  version = "~> 0.33.2"

  name        = "aws-glue-crawler-${local.metadata.name}"
  path        = "/"
  description = "Role for AWS Glue Crawler (${local.metadata.name})"

  force_detach_policies = true

  trusted_service_policies = [
    {
      services = ["glue.amazonaws.com"]
    },
  ]
  conditions = var.iam_role.conditions

  policies        = var.iam_role.policies
  inline_policies = var.iam_role.inline_policies

  resource_group_enabled = false
  module_tags_enabled    = false

  tags = merge(
    local.module_tags,
    var.tags,
  )
}

