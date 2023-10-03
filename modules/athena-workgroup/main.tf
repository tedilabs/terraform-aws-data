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

locals {
  query_result_s3_key_prefix = try(trim(var.query_result.s3_key_prefix, "/"), "")
  query_result_s3_path = (var.query_result != null
    ? "s3://${trim(var.query_result.s3_bucket, "/")}/${local.query_result_s3_key_prefix}"
    : null
  )

  engine_versions = {
    "AUTO"      = "AUTO"
    "ATHENA_V2" = "Athena engine version 2"
    "ATHENA_V3" = "Athena engine version 3"
  }
}


resource "aws_athena_workgroup" "this" {
  name        = var.name
  description = var.description

  state         = var.enabled ? "ENABLED" : "DISABLED"
  force_destroy = var.force_destroy

  configuration {
    enforce_workgroup_configuration    = !var.client_config_enabled
    publish_cloudwatch_metrics_enabled = var.cloudwatch_metrics_enabled
    requester_pays_enabled             = var.query_on_s3_requester_pays_bucket_enabled
    bytes_scanned_cutoff_per_query     = var.per_query_data_usage_limit

    engine_version {
      selected_engine_version = "AUTO"
    }

    dynamic "result_configuration" {
      for_each = local.query_result_s3_path != null ? ["go"] : []

      content {
        output_location       = local.query_result_s3_path
        expected_bucket_owner = try(var.query_result.s3_bucket_expected_owner, null)

        dynamic "encryption_configuration" {
          for_each = try(var.query_result.encryption_enabled, false) ? ["go"] : []

          content {
            encryption_option = try(var.query_result.encryption_mode, "SSE_S3")
            kms_key_arn       = try(var.query_result.encryption_kms_key, null)
          }
        }

        dynamic "acl_configuration" {
          for_each = try(var.query_result.s3_bucket_owner_full_control_enabled, false) ? ["go"] : []

          content {
            s3_acl_option = "BUCKET_OWNER_FULL_CONTROL"
          }
        }
      }
    }
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

  workgroup   = aws_athena_workgroup.this.id
  name        = each.value.name
  description = try(each.value.description, "Managed by Terraform.")

  database = each.value.database
  query    = each.value.query
}
