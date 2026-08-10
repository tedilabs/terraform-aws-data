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


###################################################
# S3 Table
###################################################

locals {
  encryption_type = {
    "AES256"  = "AES256"
    "AWS_KMS" = "aws:kms"
  }
}

resource "aws_s3tables_table" "this" {
  region = var.region

  table_bucket_arn = var.table_bucket
  namespace        = var.namespace
  name             = var.name
  format           = var.format

  ## Inherit the encryption configuration of the table bucket if not provided
  encryption_configuration = (var.encryption != null
    ? {
      sse_algorithm = local.encryption_type[var.encryption.type]
      kms_key_arn   = var.encryption.kms_key
    }
    : null
  )

  ## Only used to define the initial schema on creation. The schema is
  ## evolved by query engines afterwards.
  dynamic "metadata" {
    for_each = (anytrue([
      length(var.metadata.schema) > 0,
      length(var.metadata.properties) > 0,
    ]) ? [var.metadata] : [])

    content {
      iceberg {
        properties = length(metadata.value.properties) > 0 ? metadata.value.properties : null

        dynamic "schema" {
          for_each = length(metadata.value.schema) > 0 ? [metadata.value.schema] : []

          content {
            dynamic "field" {
              for_each = schema.value

              content {
                name     = field.value.name
                type     = field.value.type
                required = field.value.required
              }
            }
          }
        }
      }
    }
  }

  maintenance_configuration = {
    iceberg_compaction = {
      status = var.maintenance.compaction.enabled ? "enabled" : "disabled"

      settings = (var.maintenance.compaction.enabled
        ? {
          target_file_size_mb = var.maintenance.compaction.target_file_size_mb
        }
        : null
      )
    }
    iceberg_snapshot_management = {
      status = var.maintenance.snapshot_management.enabled ? "enabled" : "disabled"

      settings = (var.maintenance.snapshot_management.enabled
        ? {
          max_snapshot_age_hours = var.maintenance.snapshot_management.max_snapshot_age_hours
          min_snapshots_to_keep  = var.maintenance.snapshot_management.min_snapshots_to_keep
        }
        : null
      )
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
# Policy for S3 Table
###################################################

resource "aws_s3tables_table_policy" "this" {
  count = var.policy != null ? 1 : 0

  region = var.region

  table_bucket_arn = aws_s3tables_table.this.table_bucket_arn
  namespace        = aws_s3tables_table.this.namespace
  name             = aws_s3tables_table.this.name
  resource_policy  = var.policy
}
