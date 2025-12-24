data "aws_caller_identity" "this" {}
data "aws_region" "this" {
  region = var.region
}

locals {
  account_id = data.aws_caller_identity.this.account_id
  region     = data.aws_region.this.region

  iam_identity_center_service_role = (var.iam_identity_center.enabled && var.iam_identity_center.default_service_role.enabled
    ? one(module.role__iam_identity_center[*].arn)
    : var.iam_identity_center.service_role
  )
}


###################################################
# IAM Role
###################################################

module "role__iam_identity_center" {
  count = (var.iam_identity_center.enabled && var.iam_identity_center.default_service_role.enabled) ? 1 : 0

  source  = "tedilabs/account/aws//modules/iam-role"
  version = "~> 0.33.0"

  name = coalesce(
    var.iam_identity_center.default_service_role.name,
    "athena-workgroup-iam-identity-center-${local.metadata.name}",
  )
  path        = var.iam_identity_center.default_service_role.path
  description = var.iam_identity_center.default_service_role.description

  trusted_service_policies = [
    {
      services = ["athena.amazonaws.com"]
    },
  ]

  policies = var.iam_identity_center.default_service_role.policies
  inline_policies = merge(
    {
      "iam_identity_center" = data.aws_iam_policy_document.iam_identity_center[0].json
    },
    var.iam_identity_center.default_service_role.inline_policies
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

data "aws_iam_policy_document" "iam_identity_center" {
  count = (var.iam_identity_center.enabled && var.iam_identity_center.default_service_role.enabled) ? 1 : 0

  statement {
    sid = "Athena"

    effect = "Allow"
    actions = [
      "athena:GetPreparedStatement",
      "athena:UpdatePreparedStatement",
      "athena:GetNamedQuery",
      "athena:UpdateNamedQuery",
      "athena:ListTableMetadata",
      "athena:GetTableMetadata",
      "athena:ListDatabases",
      "athena:GetDatabase",
      "athena:ListDataCatalogs",
      "athena:GetDataCatalog",
    ]
    resources = [
      provider::aws::arn_build("aws", "athena", local.region, local.account_id, "workgroup/${var.name}"),
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [local.account_id]
    }
  }

  statement {
    sid = "Glue"

    effect = "Allow"
    actions = [
      "glue:CreateDatabase",
      "glue:DeleteDatabase",
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:UpdateDatabase",
      "glue:CreateTable",
      "glue:DeleteTable",
      "glue:BatchDeleteTable",
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
      "glue:BatchGetPartition"
    ]
    resources = [
      "*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [local.account_id]
    }
  }

  statement {
    sid = "S3Bucket"

    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
    ]
    resources = [
      provider::aws::arn_build("aws", "s3", "", "", "${var.query_result.customer_managed_query_result.s3_bucket.name}/*"),
      provider::aws::arn_build("aws", "s3", "", "", var.query_result.customer_managed_query_result.s3_bucket.name),
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [local.account_id]
    }
  }

  statement {
    sid = "S3AccessGrants"

    effect = "Allow"
    actions = [
      "s3:GetDataAccess",
      "s3:GetAccessGrantsInstanceForPrefix",
    ]
    resources = [
      provider::aws::arn_build("aws", "s3", local.region, local.account_id, "access-grants/default"),
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [local.account_id]
    }
  }

  statement {
    sid = "Lakeformation"

    effect = "Allow"
    actions = [
      "lakeformation:GetDataAccess",
    ]
    resources = [
      "*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [local.account_id]
    }
  }
}
