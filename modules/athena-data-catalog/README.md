# athena-data-catalog

This module creates following resources.

- `aws_athena_data_catalog`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.25 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.27.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.12.0 |

## Resources

| Name | Type |
|------|------|
| [aws_athena_data_catalog.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_data_catalog) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the data catalog. The catalog name must be unique for the AWS account and can use a maximum of 128 alphanumeric, underscore, at sign, or hyphen characters. | `string` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | (Required) A type of the data catalog. Valid values are `LAMBDA`, `GLUE`, `HIVE` and `FEDERATED`.<br/>    - `LAMBDA` for a federated catalog.<br/>    - `GLUE` for an AWS Glue Data Catalog.<br/>    - `HIVE` for an external hive metastore.<br/>    - `FEDERATED` for a federated catalog for which Athena creates the connection and the Lambda function for you based on the parameters that you pass. For FEDERATED type, we do not support IAM identity center. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | (Optional) The description of the data catalog. Defaults to `Managed by Terraform.`. | `string` | `"Managed by Terraform."` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | (Optional) A set of key value pairs that specifies the Lambda function or functions to use for creating the data catalog. The mapping used depends on the catalog type.<br/><br/>  `LAMBDA`<br/>    Use one of the following sets of required parameters, but not both.<br/>    - If you have one Lambda function that processes metadata and another for reading the actual data.<br/>      (Required) `metadata-function` - The ARN of Lambda function to process metadata.<br/>      (Required) `record-function` - The ARN of Lambda function to read the actual data.<br/>    - If you have a composite Lambda function that processes both metadata and data.<br/>      (Required) `function` - The ARN of a composite Lambda function to process both metadata and data.<br/><br/>  `GLUE`<br/>    (Required) `catalog-id` - The account ID of the AWS account to which the Glue Data Catalog belongs.<br/><br/>  `HIVE`<br/>    (Required) `metadata-function` - The ARN of Lambda function to process metadata.<br/>    (Optional) `sdk-version` - Defaults to the currently supported version.<br/><br/>  `FEDERATED`<br/>    Use one of the following sets of required parameters, but not both.<br/>    - For an existing Glue connection.<br/>      (Required) `connection-arn` - The ARN of the Glue connection to the data source.<br/>    - For Athena to create a new connection.<br/>      (Required) `connection-type` - The type of connection for a `FEDERATED` data catalog. Valid values are `DYNAMODB`, `MYSQL`, `POSTGRESQL`, `REDSHIFT`, `ORACLE`, `SYNAPSE`, `SQLSERVER`, `DB2`, `OPENSEARCH`, `BIGQUERY`, `GOOGLECLOUDSTORAGE`, `HBASE`, `DOCUMENTDB`, `CMDB`, `TPCDS`, `TIMESTREAM`, `SAPHANA`, `SNOWFLAKE`, `DATALAKEGEN2`, `DB2AS400`.<br/>      (Required) `connection-properties` - A JSON string that contains the properties for the new connection. The required properties vary based on the `connection-type`. | `map(string)` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the data catalog. |
| <a name="output_description"></a> [description](#output\_description) | The description of the data catalog. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the data catalog. |
| <a name="output_name"></a> [name](#output\_name) | The name of the data catalog. |
| <a name="output_parameters"></a> [parameters](#output\_parameters) | A set of key value pairs that specifies the Lambda function or functions to use for creating the data catalog. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_type"></a> [type](#output\_type) | The type of the data catalog. |
<!-- END_TF_DOCS -->
