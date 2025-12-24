output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_glue_data_catalog_encryption_settings.this.region
}

output "arn" {
  description = "The Amazon Resource Name (ARN) of the Glue Catalog."
  value       = local.arn
}

output "catalog" {
  description = "The ID of the Glue Catalog."
  value       = aws_glue_data_catalog_encryption_settings.this.catalog_id
}

output "policy" {
  description = "The policy to be applied to the aws glue data catalog for access control."
  value       = one(aws_glue_resource_policy.this[*].policy)
}

output "encryption_for_connection_passwords" {
  description = "A configuration to encrypt connection passwords in the data catalog."
  value = {
    enabled = aws_glue_data_catalog_encryption_settings.this.data_catalog_encryption_settings[0].connection_password_encryption[0].return_connection_password_encrypted
    kms_key = aws_glue_data_catalog_encryption_settings.this.data_catalog_encryption_settings[0].connection_password_encryption[0].aws_kms_key_id
  }
}

output "encryption_at_rest" {
  description = "A configuration to encrypt at rest in the data catalog."
  value = {
    enabled      = aws_glue_data_catalog_encryption_settings.this.data_catalog_encryption_settings[0].encryption_at_rest[0].catalog_encryption_mode != "DISABLED"
    mode         = aws_glue_data_catalog_encryption_settings.this.data_catalog_encryption_settings[0].encryption_at_rest[0].catalog_encryption_mode
    kms_key      = aws_glue_data_catalog_encryption_settings.this.data_catalog_encryption_settings[0].encryption_at_rest[0].sse_aws_kms_key_id
    service_role = aws_glue_data_catalog_encryption_settings.this.data_catalog_encryption_settings[0].encryption_at_rest[0].catalog_encryption_service_role
  }
}

output "resource_group" {
  description = "The resource group created to manage resources in this module."
  value = merge(
    {
      enabled = var.resource_group.enabled && var.module_tags_enabled
    },
    (var.resource_group.enabled && var.module_tags_enabled
      ? {
        arn  = module.resource_group[0].arn
        name = module.resource_group[0].name
      }
      : {}
    )
  )
}

output "sharing" {
  description = <<EOF
  The configuration for sharing of the Glue Data Catalog.
    `status` - An indication of whether the data catalog is shared with other AWS accounts, or was shared with the current account by another AWS account. Sharing is configured through AWS Resource Access Manager (AWS RAM). Values are `NOT_SHARED`, `SHARED_BY_ME` or `SHARED_WITH_ME`.
    `shares` - The list of resource shares via RAM (Resource Access Manager).
  EOF
  value = {
    status = length(module.share) > 0 ? "SHARED_BY_ME" : "NOT_SHARED"
    shares = module.share
  }
}
