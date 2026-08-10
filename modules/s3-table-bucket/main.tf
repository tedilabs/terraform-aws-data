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
# S3 Table Bucket
###################################################

locals {
  encryption_type = {
    "AES256"  = "AES256"
    "AWS_KMS" = "aws:kms"
  }
}

resource "aws_s3tables_table_bucket" "this" {
  region = var.region

  name          = var.name
  force_destroy = var.force_destroy

  encryption_configuration = {
    sse_algorithm = local.encryption_type[var.encryption.type]
    kms_key_arn   = var.encryption.kms_key
  }

  maintenance_configuration = (anytrue([
    var.maintenance.unreferenced_file_removal != null,
    ])
    ? {
      iceberg_unreferenced_file_removal = (var.maintenance.unreferenced_file_removal != null
        ? {
          status = var.maintenance.unreferenced_file_removal.enabled ? "enabled" : "disabled"

          settings = {
            unreferenced_days = var.maintenance.unreferenced_file_removal.unreferenced_days
            non_current_days  = var.maintenance.unreferenced_file_removal.non_current_days
          }
        }
        : null
      )
    }
    : null
  )

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# Namespaces for S3 Table Bucket
###################################################

resource "aws_s3tables_namespace" "this" {
  for_each = var.namespaces

  region = var.region

  table_bucket_arn = aws_s3tables_table_bucket.this.arn

  namespace = each.value
}


###################################################
# Policy for S3 Table Bucket
###################################################

resource "aws_s3tables_table_bucket_policy" "this" {
  count = var.policy != null ? 1 : 0

  region = var.region

  table_bucket_arn = aws_s3tables_table_bucket.this.arn
  resource_policy  = var.policy
}
