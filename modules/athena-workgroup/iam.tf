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
  spark_execution_role = (local.engine_type == "APACHE_SPARK" && var.default_spark_execution_role.enabled
    ? one(module.role__spark[*].arn)
    : var.spark_execution_role
  )
  spark_kms_keys = compact([
    var.customer_content_encryption.enabled ? var.customer_content_encryption.kms_key : null,
    var.logging.managed.sse_kms_key,
    var.logging.s3_bucket.sse_kms_key,
    var.calculation_result.encryption.enabled ? var.calculation_result.encryption.kms_key : null,
  ])
  spark_logging_s3_path   = trimsuffix(trimprefix(var.logging.s3_bucket.location, "s3://"), "/")
  spark_logging_s3_bucket = split("/", local.spark_logging_s3_path)[0]
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
      conditions = [
        {
          key       = "aws:SourceAccount"
          condition = "StringEquals"
          values    = [local.account_id]
        },
        {
          key       = "aws:SourceArn"
          condition = "ArnLike"
          values    = [provider::aws::arn_build("aws", "athena", local.region, local.account_id, "workgroup/${var.name}")]
        },
      ]
    },
  ]

  policies = var.iam_identity_center.default_service_role.policies
  inline_policies = merge(
    {
      "iam_identity_center" = data.aws_iam_policy_document.iam_identity_center[0].json
    },
    var.iam_identity_center.default_service_role.inline_policies
  )

  permissions_boundary = var.iam_identity_center.default_service_role.permissions_boundary

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


module "role__spark" {
  count = (local.engine_type == "APACHE_SPARK" && var.default_spark_execution_role.enabled) ? 1 : 0

  source  = "tedilabs/account/aws//modules/iam-role"
  version = "~> 0.33.0"

  name = coalesce(
    var.default_spark_execution_role.name,
    "athena-workgroup-spark-${local.metadata.name}",
  )
  path        = var.default_spark_execution_role.path
  description = var.default_spark_execution_role.description

  trusted_service_policies = [
    {
      services = ["athena.amazonaws.com"]
      conditions = [
        {
          key       = "aws:SourceAccount"
          condition = "StringEquals"
          values    = [local.account_id]
        },
        {
          key       = "aws:SourceArn"
          condition = "ArnLike"
          values    = [provider::aws::arn_build("aws", "athena", local.region, local.account_id, "workgroup/${var.name}")]
        },
      ]
    },
  ]

  policies = var.default_spark_execution_role.policies
  inline_policies = merge(
    {
      "spark" = data.aws_iam_policy_document.spark[0].json
    },
    var.default_spark_execution_role.inline_policies
  )

  permissions_boundary = var.default_spark_execution_role.permissions_boundary

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

data "aws_iam_policy_document" "spark" {
  count = (local.engine_type == "APACHE_SPARK" && var.default_spark_execution_role.enabled) ? 1 : 0

  statement {
    sid = "Athena"

    effect = "Allow"
    actions = [
      "athena:GetWorkGroup",
      "athena:CreatePresignedNotebookUrl",
      "athena:TerminateSession",
      "athena:GetSession",
      "athena:GetSessionStatus",
      "athena:ListSessions",
      "athena:StartCalculationExecution",
      "athena:GetCalculationExecutionCode",
      "athena:StopCalculationExecution",
      "athena:ListCalculationExecutions",
      "athena:GetCalculationExecution",
      "athena:GetCalculationExecutionStatus",
      "athena:ListExecutors",
      "athena:ExportNotebook",
      "athena:UpdateNotebook",
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

  dynamic "statement" {
    for_each = var.analytics_engine.version == "PYSPARK_V3" ? [var.calculation_result.s3_bucket] : []
    iterator = config

    content {
      sid = "S3CalculationResult"

      effect = "Allow"
      actions = [
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
      ]
      resources = [
        provider::aws::arn_build("aws", "s3", "", "", config.value.name),
        provider::aws::arn_build("aws", "s3", "", "", "${config.value.name}/${config.value.key_prefix}*"),
      ]
    }
  }

  dynamic "statement" {
    for_each = var.logging.s3_bucket.enabled ? ["go"] : []

    content {
      sid = "S3Logging"

      effect = "Allow"
      actions = [
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
      ]
      resources = [
        provider::aws::arn_build("aws", "s3", "", "", local.spark_logging_s3_bucket),
        provider::aws::arn_build("aws", "s3", "", "", "${local.spark_logging_s3_path}/*"),
      ]
    }
  }

  statement {
    sid = "CloudWatchLogs"

    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
    resources = concat(
      [
        provider::aws::arn_build("aws", "logs", local.region, local.account_id, "log-group:/aws-athena:*"),
        provider::aws::arn_build("aws", "logs", local.region, local.account_id, "log-group:/aws-athena*:log-stream:*"),
      ],
      (var.logging.cloudwatch.log_group != null
        ? [
          provider::aws::arn_build("aws", "logs", local.region, local.account_id, "log-group:${var.logging.cloudwatch.log_group}:*"),
          provider::aws::arn_build("aws", "logs", local.region, local.account_id, "log-group:${var.logging.cloudwatch.log_group}:log-stream:*"),
        ]
        : []
      )
    )
  }

  statement {
    sid = "CloudWatchLogGroups"

    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
    ]
    resources = [
      provider::aws::arn_build("aws", "logs", local.region, local.account_id, "log-group:*"),
    ]
  }

  statement {
    sid = "CloudWatchMetrics"

    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
    ]
    resources = [
      "*",
    ]

    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values   = ["AmazonAthenaForApacheSpark"]
    }
  }

  dynamic "statement" {
    for_each = length(local.spark_kms_keys) > 0 ? ["go"] : []

    content {
      sid = "KMS"

      effect = "Allow"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
      ]
      resources = local.spark_kms_keys
    }
  }
}
