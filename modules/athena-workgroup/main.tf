locals {
  metadata = {
    package = "terraform-aws-data"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}

data "aws_ssoadmin_instances" "default" {
  count = local.engine_type == "ATHENA_SQL" && var.iam_identity_center.enabled && (var.iam_identity_center.instance == null || var.iam_identity_center.instance == "") ? 1 : 0

  region = var.region
}

locals {
  engine_versions = {
    "AUTO"       = "AUTO"
    "ATHENA_V3"  = "Athena engine version 3"
    "PYSPARK_V3" = "PySpark engine version 3"
    "SPARK_V3.5" = "Apache Spark version 3.5"
  }
  engine_type = {
    "AUTO"       = "ATHENA_SQL"
    "ATHENA_V3"  = "ATHENA_SQL"
    "PYSPARK_V3" = "APACHE_SPARK"
    "SPARK_V3.5" = "APACHE_SPARK"
  }[var.analytics_engine.version]
}


resource "aws_athena_workgroup" "this" {
  region = var.region

  name        = var.name
  description = var.description

  state         = var.enabled ? "ENABLED" : "DISABLED"
  force_destroy = var.force_destroy

  configuration {
    ## Analytics Engine
    engine_version {
      selected_engine_version = local.engine_versions[var.analytics_engine.version]
    }


    ## Query Result (for ATHENA_SQL engine types)
    enforce_workgroup_configuration = var.query_result.override_client_config

    dynamic "managed_query_results_configuration" {
      for_each = local.engine_type == "ATHENA_SQL" ? [var.query_result] : []
      iterator = config

      content {
        enabled = config.value.management_mode == "ATHENA_MANAGED"

        dynamic "encryption_configuration" {
          for_each = config.value.management_mode == "ATHENA_MANAGED" ? [config.value.athena_managed_query_result.encryption] : []
          iterator = encryption

          content {
            kms_key = encryption.value.kms_key
          }
        }
      }
    }

    dynamic "result_configuration" {
      for_each = local.engine_type == "ATHENA_SQL" && var.query_result.management_mode == "CUSTOMER_MANAGED" ? [var.query_result.customer_managed_query_result] : []
      iterator = config

      content {
        output_location       = "s3://${config.value.s3_bucket.name}/${config.value.s3_bucket.key_prefix}"
        expected_bucket_owner = config.value.s3_bucket.expected_bucket_owner

        dynamic "acl_configuration" {
          for_each = config.value.s3_bucket.bucket_owner_full_control_enabled ? ["go"] : []

          content {
            s3_acl_option = "BUCKET_OWNER_FULL_CONTROL"
          }
        }

        dynamic "encryption_configuration" {
          for_each = config.value.encryption.enabled ? [config.value.encryption] : []
          iterator = encryption

          content {
            encryption_option = encryption.value.mode
            kms_key_arn       = contains(["SSE_KMS", "CSE_KMS"], encryption.value.mode) ? encryption.value.kms_key : null
          }
        }
      }
    }


    ## Auth
    dynamic "identity_center_configuration" {
      for_each = (local.engine_type == "ATHENA_SQL"
        ? [var.iam_identity_center]
        : []
      )
      iterator = config

      content {
        enable_identity_center = config.value.enabled
        identity_center_instance_arn = (length(data.aws_ssoadmin_instances.default) > 0
          ? data.aws_ssoadmin_instances.default[0].arns[0]
          : config.value.instance
        )
      }
    }


    ## Settings
    # For Common
    publish_cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled


    # For ATHENA_SQL engine types
    requester_pays_enabled         = local.engine_type == "ATHENA_SQL" ? var.query_on_s3_requester_pays_bucket_enabled : null
    bytes_scanned_cutoff_per_query = var.per_query_data_usage_limit


    # For APACHE_SPARK engine types
  }


  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# Named Queries
###################################################

resource "aws_athena_named_query" "this" {
  for_each = {
    for query in var.named_queries :
    "${query.database}:${query.name}" => query
  }

  region = var.region

  workgroup   = aws_athena_workgroup.this.id
  name        = each.value.name
  description = try(each.value.description, "Managed by Terraform.")

  database = each.value.database
  query    = each.value.query
}
