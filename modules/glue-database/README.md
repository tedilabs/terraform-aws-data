# glue-database

This module creates following resources.

- `aws_glue_catalog_database`
- `aws_ram_resource_share` (optional)
- `aws_ram_principal_association` (optional)
- `aws_ram_resource_association` (optional)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.65 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.19.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.10.0 |
| <a name="module_share"></a> [share](#module\_share) | tedilabs/account/aws//modules/ram-share | ~> 0.22.0 |

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
| <a name="input_location_uri"></a> [location\_uri](#input\_location\_uri) | (Optional) The location of the database. For example, an HDFS path. | `string` | `""` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | (Optional) A set of key value pairs that specifies the Lambda function or functions to use for creating the data catalog. The mapping used depends on the catalog type.<br><br>  `LAMBDA`<br>    Use one of the following sets of required parameters, but not both.<br>    - If you have one Lambda function that processes metadata and another for reading the actual data.<br>      (Required) `metadata-function` - The ARN of Lambda function to process metadata.<br>      (Required) `record-function` - The ARN of Lambda function to read the actual data.<br>    - If you have a composite Lambda function that processes both metadata and data.<br>      (Required) `function` - The ARN of a composite Lambda function to process both metadata and data.<br><br>  `GLUE`<br>    (Required) `catalog_id` - The account ID of the AWS account to which the Glue Data Catalog belongs.<br><br>  `HIVE`<br>    (Required) `metadata-function` - The ARN of Lambda function to process metadata.<br>    (Optional) `sdk-version` - Defaults to the currently supported version. | `map(string)` | `{}` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_shares"></a> [shares](#input\_shares) | (Optional) A list of resource shares via RAM (Resource Access Manager). | <pre>list(object({<br>    name = optional(string)<br><br>    # INFO<br>    # - `AWSRAMDefaultPermissionGlueDatabase`<br>    # - `AWSRAMPermissionGlueAllTablesReadWriteForDatabase`<br>    # - `AWSRAMPermissionGlueDatabaseReadWrite`<br>    # - `AWSRAMPermissionGlueTableReadWriteForDatabase`<br>    # - `AWSRAMPermissionLFTagGlueDatabaseReadWrite`<br>    # - `AWSRAMPermissionLFTagGlueTableReadWriteForDatabase`<br>    permissions = optional(set(string), ["AWSRAMDefaultPermissionGlueDatabase"])<br><br>    external_principals_allowed = optional(bool, false)<br>    principals                  = optional(set(string), [])<br><br>    tags = optional(map(string), {})<br>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the Glue Catalog Database. |
| <a name="output_catalog"></a> [catalog](#output\_catalog) | The ID of the Glue Catalog of the database. |
| <a name="output_description"></a> [description](#output\_description) | The description of the database. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the database. |
| <a name="output_location_uri"></a> [location\_uri](#output\_location\_uri) | The description of the database. |
| <a name="output_name"></a> [name](#output\_name) | The name of the database. |
| <a name="output_parameters"></a> [parameters](#output\_parameters) | A set of key value pairs that specifies the Lambda function or functions to use for creating the data catalog. |
| <a name="output_sharing"></a> [sharing](#output\_sharing) | The configuration for sharing of the Glue Database.<br>    `status` - An indication of whether the database is shared with other AWS accounts, or was shared with the current account by another AWS account. Sharing is configured through AWS Resource Access Manager (AWS RAM). Values are `NOT_SHARED`, `SHARED_BY_ME` or `SHARED_WITH_ME`.<br>    `shares` - The list of resource shares via RAM (Resource Access Manager). |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
