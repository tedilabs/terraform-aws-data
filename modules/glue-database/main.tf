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
# Database for Glue Data Catalog
###################################################

# - create_table_default_permission
#   - permissions
#   - principal
#     - data_lake_principal_identifier
# - parameters
# - target_database
#   - catalog_id
#   - database_name
resource "aws_glue_catalog_database" "this" {
  catalog_id = var.catalog

  name         = var.name
  description  = var.description
  location_uri = var.location_uri

  # parameters = var.parameters

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}
#
#
# ###################################################
# # LF Tags for Glue Database
# ###################################################
#
# resource "aws_lakeformation_resource_lf_tags" "this" {
#   catalog_id = var.catalog
#
#   database {
#     name = aws_glue_catalog_database.this.name
#   }
#
#   dynamic "lf_tag" {
#     for_each = var.lf_tags
#
#     content {
#       key   = lf_tag.key
#       value = lf_tag.value
#     }
#   }
# }
