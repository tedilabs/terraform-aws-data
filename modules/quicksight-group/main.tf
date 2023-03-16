locals {
  metadata = {
    package = "terraform-aws-data"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
  }
}

data "aws_caller_identity" "this" {}

locals {
  account_id = data.aws_caller_identity.this.account_id
}


###################################################
# QuickSight Group
###################################################

resource "aws_quicksight_group" "this" {
  namespace   = var.namespace
  group_name  = var.name
  description = var.description

  aws_account_id = local.account_id
}

resource "aws_quicksight_group_membership" "this" {
  for_each = toset(var.members)

  namespace   = aws_quicksight_group.this.namespace
  group_name  = aws_quicksight_group.this.group_name
  member_name = each.value

  aws_account_id = local.account_id
}
