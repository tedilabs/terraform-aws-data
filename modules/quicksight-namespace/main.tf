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

locals {
  role_actions = {
    "OWNER" = [
      "quicksight:CreateFolder",
      "quicksight:DescribeFolder",
      "quicksight:UpdateFolder",
      "quicksight:DeleteFolder",
      "quicksight:CreateFolderMembership",
      "quicksight:DeleteFolderMembership",
      "quicksight:DescribeFolderPermissions",
      "quicksight:UpdateFolderPermissions",
    ]
    "READER" = [
      "quicksight:DescribeFolder",
    ]
  }
}


###################################################
# QuickSight Namespace
###################################################

# INFO: Not supported attributes
# - `aws_account_id`
resource "aws_quicksight_namespace" "this" {
  namespace      = var.name
  identity_store = var.identity_store

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}
