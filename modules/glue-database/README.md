# glue-database

This module creates following resources.

- `aws_glue_catalog_database`
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
| [aws_glue_catalog_database.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the database. For Hive compatibility, this is folded to lowercase when it is stored. If you plan to access the database from Amazon Athena, then provide a name with only alphanumeric and underscore characters. The acceptable characters are lowercase letters, numbers, and the underscore character. | `string` | n/a | yes |
| <a name="input_catalog"></a> [catalog](#input\_catalog) | (Optional) The ID of the Data Catalog in which to create the database. If omitted, this defaults to the AWS Account ID. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) The description of the database. | `string` | `"Managed by Terraform."` | no |
| <a name="input_federated_database"></a> [federated\_database](#input\_federated\_database) | (Optional) A configuration of federated database to reference an entity outside the AWS Glue Data Catalog. `federated_database` as defined below.<br/>    (Optional) `id` - The unique ID for the federated database.<br/>    (Optional) `connection` - The name of the connection to the external metastore. | <pre>object({<br/>    id         = optional(string)<br/>    connection = optional(string)<br/>    # TODO:Support connection type<br/>  })</pre> | `null` | no |
| <a name="input_location_uri"></a> [location\_uri](#input\_location\_uri) | (Optional) The location URI of the database. An S3 location is required for managed tables and Zero-ETL integrations. | `string` | `""` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | (Optional) These key-value pairs define parameters and properties of the database. | `map(string)` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_shares"></a> [shares](#input\_shares) | (Optional) A list of resource shares via RAM (Resource Access Manager). | <pre>list(object({<br/>    name = optional(string)<br/><br/>    # INFO<br/>    # - `AWSRAMDefaultPermissionGlueDatabase`<br/>    # - `AWSRAMPermissionGlueAllTablesReadWriteForDatabase`<br/>    # - `AWSRAMPermissionGlueDatabaseReadWrite`<br/>    # - `AWSRAMPermissionGlueTableReadWriteForDatabase`<br/>    # - `AWSRAMPermissionLFTagGlueDatabaseReadWrite`<br/>    # - `AWSRAMPermissionLFTagGlueTableReadWriteForDatabase`<br/>    permissions = optional(set(string), ["AWSRAMDefaultPermissionGlueDatabase"])<br/><br/>    external_principals_allowed = optional(bool, false)<br/>    principals                  = optional(set(string), [])<br/><br/>    tags = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_target_database"></a> [target\_database](#input\_target\_database) | (Optional) A configuration of a target database for resource linking. `target_database` as defined below.<br/>    (Required) `catalog` - The ID of the Data Catalog in which the target database resides.<br/>    (Optional) `region` - The region in which the target database resides. If omitted, this defaults to the provider's configured region.<br/>    (Required) `database` - The name of the target database. | <pre>object({<br/>    catalog  = string<br/>    region   = optional(string)<br/>    database = string<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the Glue Catalog Database. |
| <a name="output_catalog"></a> [catalog](#output\_catalog) | The ID of the Glue Catalog of the database. |
| <a name="output_description"></a> [description](#output\_description) | The description of the database. |
| <a name="output_federated_database"></a> [federated\_database](#output\_federated\_database) | The configuration of federated database to reference an entity outside the AWS Glue Data Catalog. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the database. |
| <a name="output_location_uri"></a> [location\_uri](#output\_location\_uri) | The description of the database. |
| <a name="output_name"></a> [name](#output\_name) | The name of the database. |
| <a name="output_parameters"></a> [parameters](#output\_parameters) | A set of key value pairs that specifies the Lambda function or functions to use for creating the data catalog. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_sharing"></a> [sharing](#output\_sharing) | The configuration for sharing of the Glue Database.<br/>    `status` - An indication of whether the database is shared with other AWS accounts, or was shared with the current account by another AWS account. Sharing is configured through AWS Resource Access Manager (AWS RAM). Values are `NOT_SHARED`, `SHARED_BY_ME` or `SHARED_WITH_ME`.<br/>    `shares` - The list of resource shares via RAM (Resource Access Manager). |
| <a name="output_target_database"></a> [target\_database](#output\_target\_database) | The configuration of a target database for resource linking. |
<!-- END_TF_DOCS -->
