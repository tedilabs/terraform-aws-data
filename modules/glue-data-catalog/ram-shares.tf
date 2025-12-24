locals {
  ram_share_name_prefix = join(".", [
    "glue",
    "data-catalog",
    replace(local.account_id, "/[^a-zA-Z0-9_\\.-]/", "-"),
  ])
}


###################################################
# Resource Sharing by RAM (Resource Access Manager)
###################################################

module "share" {
  source  = "tedilabs/organization/aws//modules/ram-share"
  version = "~> 0.5.0"

  for_each = {
    for share in var.shares :
    share.name => share
  }

  region = aws_glue_data_catalog_encryption_settings.this.region

  name = "${local.ram_share_name_prefix}.${each.key}"

  resources = {
    (local.account_id) = local.arn
  }
  permissions = each.value.permissions

  external_principals_allowed = each.value.external_principals_allowed
  principals                  = each.value.principals

  resource_group = {
    enabled = false
  }
  module_tags_enabled = false

  tags = merge(
    local.module_tags,
    var.tags,
    each.value.tags,
  )
}
