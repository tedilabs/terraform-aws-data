# glue-data-catalog

This module creates following resources.

- `aws_glue_data_catalog_encryption_settings` (optional)
- `aws_glue_resource_policy` (optional)
- `aws_ram_resource_share` (optional)
- `aws_ram_principal_association` (optional)
- `aws_ram_resource_association` (optional)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.27.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.12.0 |
| <a name="module_share"></a> [share](#module\_share) | tedilabs/organization/aws//modules/ram-share | ~> 0.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_glue_data_catalog_encryption_settings.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_data_catalog_encryption_settings) | resource |
| [aws_glue_resource_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_resource_policy) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_catalog"></a> [catalog](#input\_catalog) | (Optional) The ID of the Data Catalog in which to set the security configuration for. If omitted, this defaults to the AWS Account ID. | `string` | `null` | no |
| <a name="input_encryption_at_rest"></a> [encryption\_at\_rest](#input\_encryption\_at\_rest) | (Optional) A configuration to encrypt at rest in the data catalog. When enabled, metadata stored in the data catalog is encrypted at rest. `encryption_at_rest` as defined below.<br/>    (Optional) `enabled` - Whether to enable encryption at rest. Defaults to `false`.<br/>    (Optional) `mode` - The encryption mode to use for encrypting data at rest. Valid values are `SSE-KMS` or `SSE-KMS-WITH-SERVICE-ROLE`. Defaults to `SSE-KMS`.<br/>    (Optional) `kms_key` - The ID of AWS KMS key used for the encryption.<br/>    (Optional) `service_role` - The service role to use when `mode` is set to `SSE-KMS-WITH-SERVICE-ROLE`. | <pre>object({<br/>    enabled      = optional(bool, false)<br/>    mode         = optional(string, "SSE-KMS")<br/>    kms_key      = optional(string)<br/>    service_role = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_encryption_for_connection_passwords"></a> [encryption\_for\_connection\_passwords](#input\_encryption\_for\_connection\_passwords) | (Optional) A configuration to encrypt connection passwords in the data catalog. When enabled, the password you provide when you create a connection is encrypted with the given AWS KMS key. `encryption_for_connection_passwords` as defined below.<br/>    (Optional) `enabled` - Whether to enable encryption for connection passwords. When set to `true`, passwords remain encrypted in the responses of `GetConnection` and `GetConnections`. This encryption takes effect independently of the catalog encryption. Defaults to `false`.<br/>    (Optional) `kms_key` - The ID of AWS KMS key used for the encryption. If connection password protection is enabled, the caller of `CreateConnection` and `UpdateConnection` needs at least `kms:Encrypt` permission on the specified KMS key, to encrypt passwords before storing them in the Data Catalog. You can set the decrypt permission to enable or restrict access on the password key according to your security requirements. | <pre>object({<br/>    enabled = optional(bool, false)<br/>    kms_key = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) The policy to be applied to the aws glue data catalog for access control. | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_shares"></a> [shares](#input\_shares) | (Optional) A list of resource shares via RAM (Resource Access Manager). | <pre>list(object({<br/>    name = optional(string)<br/><br/>    # INFO<br/>    # - `AWSRAMDefaultPermissionGlueCatalog`<br/>    # - `AWSRAMPermissionGlueAllTablesReadWriteForCatalog`<br/>    # - `AWSRAMPermissionGlueDatabaseReadWriteForCatalog`<br/>    # - `AWSRAMPermissionGlueTableReadWriteForCatalog`<br/>    # - `AWSRAMPermissionLFTagGlueDatabaseReadWriteForCatalog`<br/>    # - `AWSRAMPermissionLFTagGlueTableReadWriteForCatalog`<br/>    permissions = optional(set(string), ["AWSRAMDefaultPermissionGlueCatalog"])<br/><br/>    external_principals_allowed = optional(bool, false)<br/>    principals                  = optional(set(string), [])<br/><br/>    tags = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the Glue Catalog. |
| <a name="output_catalog"></a> [catalog](#output\_catalog) | The ID of the Glue Catalog. |
| <a name="output_encryption_at_rest"></a> [encryption\_at\_rest](#output\_encryption\_at\_rest) | A configuration to encrypt at rest in the data catalog. |
| <a name="output_encryption_for_connection_passwords"></a> [encryption\_for\_connection\_passwords](#output\_encryption\_for\_connection\_passwords) | A configuration to encrypt connection passwords in the data catalog. |
| <a name="output_policy"></a> [policy](#output\_policy) | The policy to be applied to the aws glue data catalog for access control. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_sharing"></a> [sharing](#output\_sharing) | The configuration for sharing of the Glue Data Catalog.<br/>    `status` - An indication of whether the data catalog is shared with other AWS accounts, or was shared with the current account by another AWS account. Sharing is configured through AWS Resource Access Manager (AWS RAM). Values are `NOT_SHARED`, `SHARED_BY_ME` or `SHARED_WITH_ME`.<br/>    `shares` - The list of resource shares via RAM (Resource Access Manager). |
<!-- END_TF_DOCS -->
