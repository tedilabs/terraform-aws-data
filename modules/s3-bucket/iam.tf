locals {
  replication_iam_role = (var.default_replication_iam_role.enabled
    ? one(module.replication_iam_role[*].arn)
    : var.replication_iam_role
  )
}


###################################################
# IAM Role for Replication
###################################################

module "replication_iam_role" {
  count = length(var.replication_rules) > 0 && var.default_replication_iam_role.enabled ? 1 : 0

  source  = "tedilabs/account/aws//modules/iam-role"
  version = "~> 0.33.5"

  name = coalesce(
    var.default_replication_iam_role.name,
    "s3-${local.metadata.name}-replication",
  )
  path        = var.default_replication_iam_role.path
  description = var.default_replication_iam_role.description

  trusted_service_policies = [
    {
      services = ["s3.amazonaws.com"]
    }
  ]

  policies = var.default_replication_iam_role.policies
  inline_policies = merge({
    "s3-replication" = jsonencode(yamldecode(<<EOF
      Version: "2012-10-17"
      Statement:
      - Effect: "Allow"
        Action:
        - "s3:GetReplicationConfiguration"
        - "s3:ListBucket"
        Resource: ["${aws_s3_bucket.this.arn}"]
      - Effect: "Allow"
        Action:
        - "s3:GetObjectVersionForReplication"
        - "s3:GetObjectVersionAcl"
        - "s3:GetObjectVersionTagging"
        %{if var.object_lock.enabled}
        - "s3:GetObjectLegalHold"
        - "s3:GetObjectRetention"
        %{endif}
        Resource: ["${aws_s3_bucket.this.arn}/*"]
      - Effect: "Allow"
        Action:
        - "s3:ReplicateObject"
        - "s3:ReplicateDelete"
        - "s3:ReplicateTags"
        # Destinations
        Resource: [
        %{for bucket in toset(var.replication_rules[*].destination.bucket)}
          ${provider::aws::arn_build("aws", "s3", "", "", bucket)}/*
        %{endfor}
        ]
    EOF
    ))
  }, var.default_replication_iam_role.inline_policies)

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
