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
# QuickSight Folder
###################################################

# INFO: Not supported attributes
# - `aws_account_id`
resource "aws_quicksight_folder" "this" {
  folder_id         = var.name
  name              = coalesce(var.display_name, var.name)
  folder_type       = var.type
  parent_folder_arn = var.parent_folder

  dynamic "permissions" {
    for_each = var.permissions

    content {
      principal = each.value.principal
      actions   = each.value.actions
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
