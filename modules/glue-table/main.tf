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
# Glue Table
###################################################


# EXTERNAL_TABLE
# Hive compatible attribute - indicates a non-Hive managed table.
#
# GOVERNED
# Used by AWS Lake Formation. The AWS Glue Data Catalog understands GOVERNED
# - partition_index
#   - index_name
#   - keys
# - partition_keys
#   - comment
#   - name
#   - type
# - retention
# - storage_descriptor
#   - bucket_columns
#   - compressed
#   - location
#   - number_of_buckets
#   - parameters
#   - schema_reference
#   - ser_de_info
#   - skewed_info
#   - sort_columns
#   - stored_as_sub_directories
# - table_type
# - target_table
#   - catalog_id
#   - database_name
#   - name
# - view_expanded_text
# - view_original_text
resource "aws_glue_catalog_table" "this" {
  catalog_id    = var.catalog
  database_name = var.database

  name        = var.name
  description = var.description
  owner       = var.owner

  storage_descriptor {
    input_format  = var.input_format
    output_format = var.output_format

    dynamic "columns" {
      for_each = var.columns
      iterator = column

      content {
        name = column.value.name
        type = column.value.type

        comment    = column.value.comment
        parameters = column.value.parameters
      }
    }
  }

  parameters = var.parameters
}
