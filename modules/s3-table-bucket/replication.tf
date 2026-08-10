locals {
  replication_enabled = length(var.replication.rules) > 0
  replication_service_role = (var.replication.default_service_role.enabled
    ? one(module.replication_service_role[*].arn)
    : var.replication.service_role
  )
  replication_destinations = distinct(flatten(var.replication.rules[*].destinations))
}


###################################################
# Replication for S3 Table Bucket
###################################################

resource "aws_s3tables_table_bucket_replication" "this" {
  count = local.replication_enabled ? 1 : 0

  region = var.region

  table_bucket_arn = aws_s3tables_table_bucket.this.arn
  role             = local.replication_service_role

  dynamic "rule" {
    for_each = var.replication.rules

    content {
      dynamic "destination" {
        for_each = rule.value.destinations

        content {
          destination_table_bucket_arn = destination.value
        }
      }
    }
  }
}


###################################################
# IAM Role for Replication
###################################################

# INFO: Add KMS permissions with `default_service_role.policies` or
# `default_service_role.inline_policies` if the tables are encrypted with KMS.
module "replication_service_role" {
  count = (local.replication_enabled && var.replication.default_service_role.enabled) ? 1 : 0

  source  = "tedilabs/account/aws//modules/iam-role"
  version = "~> 0.33.0"

  name = coalesce(
    var.replication.default_service_role.name,
    "s3tables-${local.metadata.name}-replication",
  )
  path        = var.replication.default_service_role.path
  description = var.replication.default_service_role.description

  trusted_service_policies = [
    {
      services = ["replication.s3tables.amazonaws.com"]
    }
  ]

  policies = var.replication.default_service_role.policies
  inline_policies = merge({
    "s3tables-replication" = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "SourceTableBucketPermissions"
          Effect   = "Allow"
          Action   = ["s3tables:ListTables"]
          Resource = [aws_s3tables_table_bucket.this.arn]
        },
        {
          Sid    = "SourceTablesPermissions"
          Effect = "Allow"
          Action = [
            "s3tables:GetTable",
            "s3tables:GetTableData",
            "s3tables:GetTableMetadataLocation",
            "s3tables:GetTableMaintenanceConfiguration",
          ]
          Resource = ["${aws_s3tables_table_bucket.this.arn}/table/*"]
        },
        {
          Sid    = "DestinationTableBucketsPermissions"
          Effect = "Allow"
          Action = [
            "s3tables:CreateNamespace",
            "s3tables:CreateTable",
          ]
          Resource = local.replication_destinations
        },
        {
          Sid    = "DestinationTablesPermissions"
          Effect = "Allow"
          Action = [
            "s3tables:GetTableData",
            "s3tables:PutTableData",
            "s3tables:PutTableMaintenanceConfiguration",
            "s3tables:UpdateTableMetadataLocation",
          ]
          Resource = [
            for destination in local.replication_destinations :
            "${destination}/table/*"
          ]
        },
      ]
    })
  }, var.replication.default_service_role.inline_policies)

  permissions_boundary = var.replication.default_service_role.permissions_boundary

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
