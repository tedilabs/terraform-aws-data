# glue-table

This module creates following resources.

- `aws_glue_catalog_table`
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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.33.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.12.0 |
| <a name="module_share"></a> [share](#module\_share) | tedilabs/organization/aws//modules/ram-share | ~> 0.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_glue_catalog_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_database"></a> [database](#input\_database) | (Required) The name of the metadata database where the table metadata resides. For Hive compatibility, this name must be all lowercase. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the table. For Hive compatibility, this must be entirely lowercase. | `string` | n/a | yes |
| <a name="input_catalog"></a> [catalog](#input\_catalog) | (Optional) The ID of the Data Catalog in which to create the table. If omitted, this defaults to the AWS Account ID. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) The description of the table. Defaults to `Managed by Terraform.`. | `string` | `"Managed by Terraform."` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | (Optional) The table owner. Included for Apache Hive compatibility. Not used in the normal course of Glue operations. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_shares"></a> [shares](#input\_shares) | (Optional) A list of resource shares via RAM (Resource Access Manager). | <pre>list(object({<br/>    name = optional(string)<br/><br/>    # INFO<br/>    # - `AWSRAMDefaultPermissionGlueTable`<br/>    # - `AWSRAMPermissionGlueDatabaseReadWriteForTable`<br/>    # - `AWSRAMPermissionGlueTableReadWrite`<br/>    # - `AWSRAMPermissionLFTagGlueDatabaseReadWriteForTable`<br/>    # - `AWSRAMPermissionLFTagGlueTableReadWrite`<br/>    permissions = optional(set(string), ["AWSRAMDefaultPermissionGlueTable"])<br/><br/>    external_principals_allowed = optional(bool, false)<br/>    principals                  = optional(set(string), [])<br/><br/>    tags = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_type"></a> [type](#input\_type) | (Optional) The type of this table. AWS Glue will create tables with the `EXTERNAL_TABLE` type. Valid values are `EXTERNAL_TABLE`, `GOVERNED`. Defaults to `EXTERNAL_TABLE`.<br/><br/>  `EXTERNAL_TABLE` - Hive compatible attribute, indicates a non-Hive managed table.<br/>  `GOVERNED` - Used by AWS Lake Formation. The AWS Glue Data Catalog understands `GOVERNED`. | `string` | `"EXTERNAL_TABLE"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the Glue Catalog Table. |
| <a name="output_catalog"></a> [catalog](#output\_catalog) | The ID of the Glue Catalog of the table. |
| <a name="output_database"></a> [database](#output\_database) | The catalog database in which to create the new table. |
| <a name="output_description"></a> [description](#output\_description) | The description of the table. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the database. |
| <a name="output_name"></a> [name](#output\_name) | The name of the table. |
| <a name="output_owner"></a> [owner](#output\_owner) | The table owner. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_sharing"></a> [sharing](#output\_sharing) | The configuration for sharing of the Glue Table.<br/>    `status` - An indication of whether the table is shared with other AWS accounts, or was shared with the current account by another AWS account. Sharing is configured through AWS Resource Access Manager (AWS RAM). Values are `NOT_SHARED`, `SHARED_BY_ME` or `SHARED_WITH_ME`.<br/>    `shares` - The list of resource shares via RAM (Resource Access Manager). |
| <a name="output_type"></a> [type](#output\_type) | The type of the table. |
<!-- END_TF_DOCS -->
