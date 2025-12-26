locals {
  security_groups = setunion(
    module.security_group[*].id,
    var.vpc_association.security_groups,
  )
}


###################################################
# Security Group
###################################################

module "security_group" {
  source  = "tedilabs/network/aws//modules/security-group"
  version = "~> 1.2.0"

  count = (var.vpc_association.enabled && var.vpc_association.default_security_group.enabled) ? 1 : 0

  region = var.region

  name        = coalesce(var.vpc_association.default_security_group.name, local.metadata.name)
  description = var.vpc_association.default_security_group.description
  vpc_id      = local.vpc_id

  ingress_rules = concat(
    var.vpc_association.default_security_group.ingress_rules,
    [
      {
        id          = "glue-tcp"
        description = "Allow all TCP traffic from self."
        protocol    = "tcp"
        from_port   = 0
        to_port     = 65535

        self = true
      }
    ]
  )
  egress_rules = concat(
    var.vpc_association.default_security_group.egress_rules,
    [
      {
        id          = "glue-all"
        description = "Allow all traffic from self."
        protocol    = -1
        from_port   = 0
        to_port     = 65535

        ipv4_cidrs = ["0.0.0.0/0"]
        ipv6_cidrs = ["::/0"]
        self       = true
      }
    ]
  )

  revoke_rules_on_delete = true
  resource_group = {
    enabled = false
  }
  module_tags_enabled = false

  tags = merge(
    local.module_tags,
    var.tags,
  )
}
