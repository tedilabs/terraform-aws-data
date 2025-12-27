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

data "aws_subnet" "this" {
  count = var.vpc_association.enabled ? 1 : 0

  region = var.region

  id = var.vpc_association.subnet
}

locals {
  vpc_id            = var.vpc_association.enabled ? data.aws_subnet.this[0].vpc_id : null
  availability_zone = var.vpc_association.enabled ? data.aws_subnet.this[0].availability_zone : null
}


###################################################
# Glue Connection
###################################################

resource "aws_glue_connection" "this" {
  region = var.region

  catalog_id = var.catalog

  name        = var.name
  description = var.description

  connection_type       = var.type
  connection_properties = var.properties
  athena_properties     = var.athena_properties

  # INFO: Need to communicate with RDS, S3, SecretsManager resources.
  dynamic "physical_connection_requirements" {
    for_each = var.vpc_association.enabled ? [var.vpc_association] : []
    iterator = association

    content {
      availability_zone      = local.availability_zone
      subnet_id              = association.value.subnet
      security_group_id_list = local.security_groups
    }
  }

  match_criteria = var.match_criteria

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}
