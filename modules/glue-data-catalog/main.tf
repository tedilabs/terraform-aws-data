locals {
  metadata = {
    package = "terraform-aws-data"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = local.account_id
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}

data "aws_caller_identity" "this" {}
data "aws_partition" "this" {}
data "aws_region" "this" {
  region = var.region
}

locals {
  account_id = data.aws_caller_identity.this.account_id
  partition  = data.aws_partition.this.partition
  region     = data.aws_region.this.region
  arn        = provider::aws::arn_build(local.partition, "glue", local.region, local.account_id, "catalog")
}


###################################################
# Encryption options for Glue Data Catalog
###################################################

resource "aws_glue_data_catalog_encryption_settings" "this" {
  region = var.region

  catalog_id = var.catalog

  data_catalog_encryption_settings {
    connection_password_encryption {
      return_connection_password_encrypted = var.encryption_for_connection_passwords.enabled
      aws_kms_key_id = (var.encryption_for_connection_passwords.enabled
        ? var.encryption_for_connection_passwords.kms_key
        : null
      )
    }

    encryption_at_rest {
      catalog_encryption_mode = var.encryption_at_rest.enabled ? var.encryption_at_rest.mode : "DISABLED"
      sse_aws_kms_key_id = (var.encryption_at_rest.enabled
        ? var.encryption_at_rest.kms_key
        : null
      )
      catalog_encryption_service_role = (var.encryption_at_rest.enabled
        ? var.encryption_at_rest.service_role
        : null
      )
    }
  }
}


###################################################
# Resource Policy for Glue Data Catalog
###################################################

resource "aws_glue_resource_policy" "this" {
  count = length(var.policy) > 0 ? 1 : 0

  region = var.region

  policy        = var.policy
  enable_hybrid = "TRUE"
}
