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

# TODO: LakeFormation Only
# create_table_default_permission - (Optional) Creates a set of default permissions on the table for principals. See create_table_default_permission below.
#   - permissions
#   - principal
#     - data_lake_principal_identifier
resource "aws_glue_catalog_database" "this" {
  region = var.region

  catalog_id = var.catalog

  name = var.name
  description = (var.target_database == null
    ? var.description
    : null
  )
  location_uri = var.location_uri

  parameters = var.parameters


  ## Federated
  dynamic "federated_database" {
    for_each = var.federated_database != null ? [var.federated_database] : []
    iterator = db

    content {
      identifier      = db.value.id
      connection_name = db.value.connection
    }
  }


  ## LakeFormation
  # TODO: Ignore description, parameter for target_database
  dynamic "target_database" {
    for_each = var.target_database != null ? [var.target_database] : []
    iterator = db

    content {
      catalog_id    = db.value.catalog
      region        = db.value.region
      database_name = db.value.database
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
