# glue-table

This module creates following resources.

- `aws_glue_catalog_table`
- `aws_ram_resource_share` (optional)
- `aws_ram_principal_association` (optional)
- `aws_ram_resource_association` (optional)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.13 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.13 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.12.0 |
| <a name="module_share"></a> [share](#module\_share) | tedilabs/organization/aws//modules/ram-share | ~> 0.5.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_glue_catalog_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_database"></a> [database](#input\_database) | (Required) The name of the metadata database where the table metadata resides. For Hive compatibility, this name must be all lowercase. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the table. For Hive compatibility, this must be entirely lowercase. | `string` | n/a | yes |
| <a name="input_catalog"></a> [catalog](#input\_catalog) | (Optional) The ID of the Data Catalog in which to create the table. If omitted, this defaults to the AWS Account ID. | `string` | `null` | no |
| <a name="input_columns"></a> [columns](#input\_columns) | (Optional) A list of the configurations for columns in the table. Each item of `columns` as defined below.<br/>    (Required) `name` - The name of the Column.<br/>    (Required) `type` - The data type of the Column.<br/>    (Optional) `comment` - A free-form text comment.<br/>    (Optional) `parameters` - A properties associated with the column, as a map of key-value pairs. | <pre>list(object({<br/>    name       = string<br/>    type       = string<br/>    comment    = optional(string, "")<br/>    parameters = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_compressed"></a> [compressed](#input\_compressed) | (Optional) Whether the data in the table is compressed. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) The description of the table. Defaults to `Managed by Terraform.`. | `string` | `"Managed by Terraform."` | no |
| <a name="input_input_format"></a> [input\_format](#input\_input\_format) | (Optional) Absolute class name of the Hadoop `InputFormat` to use when reading table files. Supported values are following:<br/>    `org.apache.hadoop.hive.ql.io.avro.AvroContainerInputFormat` - InputFormat for Avro files.<br/>    `com.amazon.emr.cloudtrail.CloudTrailInputFormat` - InputFormat for Cloudtrail Logs.<br/>    `org.apache.hadoop.hive.ql.io.orc.OrcInputFormat` - InputFormat for Orc files.<br/>    `org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat` - InputFormat for Parquet files.<br/>    `org.apache.hadoop.mapred.TextInputFormat` - An InputFormat for plain text files. Files are broken into lines. Either linefeed or carriage-return are used to signal end of line. Keys are the position in the file, and values are the line of text. JSON & CSV files are examples of this InputFormat. | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | (Optional) The physical location of the table. By default, this takes the form of the warehouse location, followed by the database location in the warehouse, followed by the table name. | `string` | `null` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_output_format"></a> [output\_format](#input\_output\_format) | (Optional) Absolute class name of the Hadoop `OutputFormat` to use when writing table files. Supported values are following:<br/>    `org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat` - Writes text data with a null key (value only).<br/>    `org.apache.hadoop.hive.ql.io.avro.AvroContainerOutputFormat` - OutputFormat for Avro files.<br/>    `org.apache.hadoop.hive.ql.io.orc.OrcOutputFormat` - OutputFormat for Orc files.<br/>    `org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat` - OutputFormat for Parquet files. | `string` | `""` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | (Optional) The table owner. Included for Apache Hive compatibility. Not used in the normal course of Glue operations. | `string` | `null` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | (Optional) A properties associated with this table, as a map of key-value pairs. | `map(string)` | `{}` | no |
| <a name="input_partition_keys"></a> [partition\_keys](#input\_partition\_keys) | (Optional) A list of columns by which the table is partitioned. Only primitive types are supported as partition keys. Each item of `partition_keys` as defined below.<br/>    (Required) `name` - The name of the partition key.<br/>    (Required) `type` - The data type of the partition key.<br/>    (Optional) `comment` - A free-form text comment. | <pre>list(object({<br/>    name    = string<br/>    type    = string<br/>    comment = optional(string, "")<br/>  }))</pre> | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_ser_de"></a> [ser\_de](#input\_ser\_de) | (Optional) A configuration of the SerDe (Serializer/Deserializer) of the table. `ser_de` as defined below.<br/>    (Optional) `name` - The name of the SerDe.<br/>    (Optional) `serialization_library` - Absolute class name of the SerDe library, which is used by the table for serialization and deserialization of rows. For example, `org.openx.data.jsonserde.JsonSerDe`.<br/>    (Optional) `parameters` - A map of initialization parameters for the SerDe, in key-value form. | <pre>object({<br/>    name                  = optional(string)<br/>    serialization_library = optional(string)<br/>    parameters            = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| <a name="input_shares"></a> [shares](#input\_shares) | (Optional) A list of resource shares via RAM (Resource Access Manager). | <pre>list(object({<br/>    name = optional(string)<br/><br/>    # INFO<br/>    # - `AWSRAMDefaultPermissionGlueTable`<br/>    # - `AWSRAMPermissionGlueDatabaseReadWriteForTable`<br/>    # - `AWSRAMPermissionGlueTableReadWrite`<br/>    # - `AWSRAMPermissionLFTagGlueDatabaseReadWriteForTable`<br/>    # - `AWSRAMPermissionLFTagGlueTableReadWrite`<br/>    permissions = optional(set(string), ["AWSRAMDefaultPermissionGlueTable"])<br/><br/>    external_principals_allowed = optional(bool, false)<br/>    principals                  = optional(set(string), [])<br/><br/>    tags = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_type"></a> [type](#input\_type) | (Optional) The type of this table. AWS Glue will create tables with the `EXTERNAL_TABLE` type. Valid values are `EXTERNAL_TABLE`, `GOVERNED`. Defaults to `EXTERNAL_TABLE`.<br/><br/>  `EXTERNAL_TABLE` - Hive compatible attribute, indicates a non-Hive managed table.<br/>  `GOVERNED` - Used by AWS Lake Formation. The AWS Glue Data Catalog understands `GOVERNED`. | `string` | `"EXTERNAL_TABLE"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the Glue Catalog Table. |
| <a name="output_catalog"></a> [catalog](#output\_catalog) | The ID of the Glue Catalog of the table. |
| <a name="output_columns"></a> [columns](#output\_columns) | A list of the configurations for columns in the table. |
| <a name="output_compressed"></a> [compressed](#output\_compressed) | Whether the data in the table is compressed. |
| <a name="output_database"></a> [database](#output\_database) | The catalog database in which to create the new table. |
| <a name="output_description"></a> [description](#output\_description) | The description of the table. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the database. |
| <a name="output_input_format"></a> [input\_format](#output\_input\_format) | Absolute class name of the Hadoop `InputFormat` to use when reading table files. |
| <a name="output_location"></a> [location](#output\_location) | The physical location of the table. |
| <a name="output_name"></a> [name](#output\_name) | The name of the table. |
| <a name="output_output_format"></a> [output\_format](#output\_output\_format) | Absolute class name of the Hadoop `OutputFormat` to use when writing table files. |
| <a name="output_owner"></a> [owner](#output\_owner) | The table owner. |
| <a name="output_parameters"></a> [parameters](#output\_parameters) | The properties associated with this table, as a map of key-value pairs. |
| <a name="output_partition_keys"></a> [partition\_keys](#output\_partition\_keys) | A list of columns by which the table is partitioned. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_ser_de"></a> [ser\_de](#output\_ser\_de) | The configuration of the SerDe (Serializer/Deserializer) of the table. |
| <a name="output_sharing"></a> [sharing](#output\_sharing) | The configuration for sharing of the Glue Table.<br/>    `status` - An indication of whether the table is shared with other AWS accounts, or was shared with the current account by another AWS account. Sharing is configured through AWS Resource Access Manager (AWS RAM). Values are `NOT_SHARED`, `SHARED_BY_ME` or `SHARED_WITH_ME`.<br/>    `shares` - The list of resource shares via RAM (Resource Access Manager). |
| <a name="output_type"></a> [type](#output\_type) | The type of the table. |
<!-- END_TF_DOCS -->
