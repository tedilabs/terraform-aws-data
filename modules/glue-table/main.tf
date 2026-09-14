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

# - partition_index
#   - index_name
#   - keys
# - retention
# - storage_descriptor
#   - bucket_columns
#   - number_of_buckets
#   - parameters
#   - schema_reference
#   - skewed_info
#   - sort_columns
#   - stored_as_sub_directories
# - target_table
#   - catalog_id
#   - database_name
#   - name
# - view_expanded_text
# - view_original_text
resource "aws_glue_catalog_table" "this" {
  region = var.region

  catalog_id    = var.catalog
  database_name = var.database
  owner         = var.owner

  name        = var.name
  description = var.description
  table_type  = var.type

  dynamic "partition_keys" {
    for_each = var.partition_keys
    iterator = key

    content {
      name    = key.value.name
      type    = key.value.type
      comment = key.value.comment
    }
  }

  storage_descriptor {
    location      = var.location
    input_format  = var.input_format != "" ? var.input_format : null
    output_format = var.output_format != "" ? var.output_format : null
    compressed    = var.compressed

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

    dynamic "ser_de_info" {
      for_each = (var.ser_de.name != null || var.ser_de.serialization_library != null
        ? [var.ser_de]
        : []
      )

      content {
        name                  = ser_de_info.value.name
        serialization_library = ser_de_info.value.serialization_library
        parameters            = ser_de_info.value.parameters
      }
    }
  }

  parameters = var.parameters
}
