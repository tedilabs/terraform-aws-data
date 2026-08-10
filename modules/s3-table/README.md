# s3-table

This module creates following resources.

- `aws_s3tables_table`
- `aws_s3tables_table_policy` (optional)
- `aws_s3tables_table_replication` (optional)

## Notes

- `metadata.schema` only defines the initial schema when the table is created. The schema is evolved by query engines (Athena, Spark, ...) afterwards. Tables created by query engines are not managed by this module.
- `metadata.properties` forces a new table to be created when changed. Review the plan output carefully before applying.
- `policy` determines whether to create the policy resource, so it must be known at plan time. Avoid interpolating values that are unknown until apply (e.g. generated table names) in the policy document. Use `*` to refer to the resources the policy is attached to instead.
- The replication configuration is a singleton per table, and overrides the bucket-level replication configuration for this table. The service currently supports only one rule per replication configuration, and each rule supports up to 5 destinations. The default service role only includes `s3tables` permissions — add KMS permissions with `replication.default_service_role.policies` or `inline_policies` if the table is encrypted with KMS.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.57 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.58.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_replication_service_role"></a> [replication\_service\_role](#module\_replication\_service\_role) | tedilabs/account/aws//modules/iam-role | ~> 0.33.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.12.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_s3tables_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3tables_table) | resource |
| [aws_s3tables_table_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3tables_table_policy) | resource |
| [aws_s3tables_table_replication.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3tables_table_replication) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | (Required) Desired name for the S3 table. Must be between 1 and 255 characters in length. Can consist of lowercase letters, numbers, and underscores, and must begin and end with a lowercase letter or number. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | (Required) The name of the namespace for the table. The namespace must exist in the table bucket. | `string` | n/a | yes |
| <a name="input_table_bucket"></a> [table\_bucket](#input\_table\_bucket) | (Required) The ARN of the S3 table bucket to create the table in. | `string` | n/a | yes |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | (Optional) A configurations of Server-Side Encryption for the S3 table. If not provided, the table inherits the encryption configuration of the table bucket. `encryption` as defined below.<br/>    (Optional) `type` - The server-side encryption algorithm to use. Valid values are `AES256` and `AWS_KMS`. Defaults to `AES256`.<br/>    (Optional) `kms_key` - The ARN of the AWS KMS key used for the `SSE-KMS` encryption. This can only be used when you set the value of `encryption.type` as `AWS_KMS`. | <pre>object({<br/>    type    = optional(string, "AES256")<br/>    kms_key = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_format"></a> [format](#input\_format) | (Optional) The format of the table. Only `ICEBERG` is supported. Defaults to `ICEBERG`. | `string` | `"ICEBERG"` | no |
| <a name="input_maintenance"></a> [maintenance](#input\_maintenance) | (Optional) A configurations of maintenance for the S3 table. `compaction` and `snapshot_management` can be configured independently, and each is enabled by default. `maintenance` as defined below.<br/>    (Optional) `compaction` - A configuration for the Iceberg compaction maintenance, which combines small data objects to improve query performance. `compaction` as defined below.<br/>      (Optional) `enabled` - Whether the compaction maintenance is enabled. Defaults to `true`.<br/>      (Optional) `target_file_size_mb` - The target file size in MB. Data objects smaller than this size may be combined with others to improve query performance. Must be between `64` and `512`. Defaults to `512`.<br/>    (Optional) `snapshot_management` - A configuration for the Iceberg snapshot management maintenance, which deletes old table snapshots. `snapshot_management` as defined below.<br/>      (Optional) `enabled` - Whether the snapshot management maintenance is enabled. Defaults to `true`.<br/>      (Optional) `max_snapshot_age_hours` - Snapshots older than this many hours will be marked for deletion. Must be at least `1`. Defaults to `120`.<br/>      (Optional) `min_snapshots_to_keep` - The minimum number of snapshots to keep. Must be at least `1`. Defaults to `1`. | <pre>object({<br/>    compaction = optional(object({<br/>      enabled             = optional(bool, true)<br/>      target_file_size_mb = optional(number, 512)<br/>    }), {})<br/>    snapshot_management = optional(object({<br/>      enabled                = optional(bool, true)<br/>      max_snapshot_age_hours = optional(number, 120)<br/>      min_snapshots_to_keep  = optional(number, 1)<br/>    }), {})<br/>  })</pre> | `{}` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | (Optional) A configuration of the metadata for the Iceberg table. Only used to define the initial metadata when the table is created. The schema is evolved by query engines afterwards. `metadata` as defined below.<br/>    (Optional) `schema` - A list of schema fields for the Iceberg table. Each field defines a column in the table schema, and the order of the fields defines the column order. Each value of `schema` as defined below.<br/>      (Required) `name` - The name of the field.<br/>      (Required) `type` - The field type. S3 Tables supports all Apache Iceberg primitive types including `boolean`, `int`, `long`, `float`, `double`, `decimal(precision,scale)`, `date`, `time`, `timestamp`, `timestamptz`, `string`, `uuid`, `fixed(length)`, `binary`.<br/>      (Optional) `required` - Whether values are required for each row in this field. Defaults to `false`.<br/>    (Optional) `properties` - A map of configuration properties for the Iceberg table, for example `write.distribution-mode` and `write.sort-order`. Can only be used with `schema`. Changing this forces a new table to be created. | <pre>object({<br/>    schema = optional(list(object({<br/>      name     = string<br/>      type     = string<br/>      required = optional(bool, false)<br/>    })), [])<br/>    properties = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A valid resource policy JSON document for the S3 table. Although this is a table policy, not an IAM policy, the `aws_iam_policy_document` data source may be used, so long as it specifies a principal. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_replication"></a> [replication](#input\_replication) | (Optional) A configurations of Replication for the S3 table. The table-level replication configuration overrides the bucket-level replication configuration for this table. `replication` as defined below.<br/>    (Optional) `rules` - A list of replication rules. The service currently supports only one rule per replication configuration. Each value of `rules` as defined below.<br/>      (Required) `destinations` - A set of ARNs of the destination table buckets to replicate the source table to. Each rule supports up to 5 destinations.<br/>    (Optional) `service_role` - The ARN (Amazon Resource Name) of the IAM Role that Amazon S3 assumes when replicating the table. Only required if `replication.default_service_role.enabled` is `false`.<br/>    (Optional) `default_service_role` - A configuration for the default service role for the table replication. Use `replication.service_role` if `replication.default_service_role.enabled` is `false`. Add KMS permissions with `policies` or `inline_policies` if the table is encrypted with KMS. `default_service_role` as defined below.<br/>      (Optional) `enabled` - Whether to create the default service role. Defaults to `true`.<br/>      (Optional) `name` - The name of the default service role. Defaults to `s3tables-${bucket-name}-${var.name}-replication`.<br/>      (Optional) `path` - The path of the default service role. Defaults to `/`.<br/>      (Optional) `description` - The description of the default service role.<br/>      (Optional) `policies` - A list of IAM policy ARNs to attach to the default service role. Defaults to `[]`.<br/>      (Optional) `inline_policies` - A Map of inline IAM policies to attach to the default service role. (`name` => `policy`).<br/>      (Optional) `permissions_boundary` - The ARN of the IAM policy to use as permissions boundary for the default service role. | <pre>object({<br/>    rules = optional(list(object({<br/>      destinations = set(string)<br/>    })), [])<br/><br/>    service_role = optional(string)<br/>    default_service_role = optional(object({<br/>      enabled     = optional(bool, true)<br/>      name        = optional(string)<br/>      path        = optional(string, "/")<br/>      description = optional(string, "Managed by Terraform.")<br/><br/>      policies             = optional(list(string), [])<br/>      inline_policies      = optional(map(string), {})<br/>      permissions_boundary = optional(string)<br/>    }), {})<br/>  })</pre> | `{}` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the table. |
| <a name="output_created_at"></a> [created\_at](#output\_created\_at) | Date and time when the table was created. |
| <a name="output_created_by"></a> [created\_by](#output\_created\_by) | The account ID of the account that created the table. |
| <a name="output_debug"></a> [debug](#output\_debug) | n/a |
| <a name="output_encryption"></a> [encryption](#output\_encryption) | The configuration for the Server-Side Encryption of the table. `override` indicates whether the table overrides the encryption configuration of the table bucket. |
| <a name="output_format"></a> [format](#output\_format) | The format of the table. |
| <a name="output_maintenance"></a> [maintenance](#output\_maintenance) | The maintenance configuration of the table. |
| <a name="output_metadata"></a> [metadata](#output\_metadata) | The metadata of the table. Only reflects the initial metadata defined when the table was created. The schema is evolved by query engines afterwards. |
| <a name="output_metadata_location"></a> [metadata\_location](#output\_metadata\_location) | The location of table metadata. |
| <a name="output_name"></a> [name](#output\_name) | The name of the table. |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | The name of the namespace for the table. |
| <a name="output_owner"></a> [owner](#output\_owner) | The account ID of the account that owns the table. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_replication"></a> [replication](#output\_replication) | The replication configuration of the table. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_table_bucket"></a> [table\_bucket](#output\_table\_bucket) | The ARN of the table bucket that contains the table. |
| <a name="output_type"></a> [type](#output\_type) | The type of the table. One of `customer` or `aws`. |
| <a name="output_updated_at"></a> [updated\_at](#output\_updated\_at) | Date and time when the table was last modified. |
| <a name="output_updated_by"></a> [updated\_by](#output\_updated\_by) | The account ID of the account that last modified the table. |
| <a name="output_version_token"></a> [version\_token](#output\_version\_token) | The identifier for the current version of table data. |
| <a name="output_warehouse_location"></a> [warehouse\_location](#output\_warehouse\_location) | The S3 URI pointing to the S3 bucket that contains the table data. |
<!-- END_TF_DOCS -->
