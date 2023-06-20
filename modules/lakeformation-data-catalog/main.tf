locals {
  metadata = {
    package = "terraform-aws-data"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = local.account_id
  }
}

data "aws_caller_identity" "this" {}

locals {
  account_id = data.aws_caller_identity.this.account_id
}


###################################################
# Settings for Lake Formation Data Catalog
###################################################

resource "aws_lakeformation_data_lake_settings" "this" {
  catalog_id = var.catalog

  admins = var.admins
}


###################################################
# LF Tags for Lake Formation Data Catalog
###################################################

resource "aws_lakeformation_lf_tag" "this" {
  for_each = var.lf_tags

  catalog_id = var.catalog

  key    = each.key
  values = each.value
}
