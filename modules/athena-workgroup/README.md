# athena-workgroup

This module creates following resources.

- `aws_athena_workgroup`
- `aws_athena_named_query` (optional)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.71 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_athena_named_query.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query) | resource |
| [aws_athena_workgroup.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_workgroup) | resource |
| [aws_resourcegroups_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/resourcegroups_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the workgroup. | `string` | n/a | yes |
| <a name="input_client_config_enabled"></a> [client\_config\_enabled](#input\_client\_config\_enabled) | (Optional) Whether overriding workgroup configurations with client-side configurations is allowed. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_cloudwatch_metrics_enabled"></a> [cloudwatch\_metrics\_enabled](#input\_cloudwatch\_metrics\_enabled) | (Optional) Whether Amazon CloudWatch metrics are enabled for the workgroup. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) The description of the workgroup. | `string` | `"Managed by Terraform."` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | (Optional) | `bool` | `true` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | (Optional) Whether to delete the workgroup and its contents even if the workgroup contains any named queries. | `bool` | `false` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_named_queries"></a> [named\_queries](#input\_named\_queries) | (Optional) Save named queries to reuse later. A `named_queries` block as defined below.<br>    (Required) `name` - The plain language name for the query. Maximum length of 128.<br>    (Optional) `description` - A brief explanation of the query. Maximum length of 1024.<br>    (Required) `database` - The database to which the query belongs.<br>    (Required) `query` - The text of the query itself. In other words, all query statements. Maximum length of 262144. | `list(map(string))` | `[]` | no |
| <a name="input_per_query_data_usage_limit"></a> [per\_query\_data\_usage\_limit](#input\_per\_query\_data\_usage\_limit) | (Optional) Sets the limit in bytes for the maximum amount of data a query is allowed to scan. You can set only one per query limit for a workgroup. The limit applies to all queries in the workgroup and if query exceeds the limit, it will be cancelled. Minimum limit is 10 MB and maximum limit is 7EB per workgroup. | `number` | `null` | no |
| <a name="input_query_on_s3_requester_pays_bucket_enabled"></a> [query\_on\_s3\_requester\_pays\_bucket\_enabled](#input\_query\_on\_s3\_requester\_pays\_bucket\_enabled) | (Optional) Whether to allow members assigned to a workgroup to reference Amazon S3 Requester Pays buckets in queries. If set to false, workgroup members cannot query data from Requester Pays buckets, and queries that retrieve data from Requester Pays buckets cause an error. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_query_result"></a> [query\_result](#input\_query\_result) | (Optional) The configuration for query result location and encryption. A `query_result` block as defined below.<br>    (Required) `s3_bucket` - The name of the S3 bucket used to store the query result.<br>    (Optional) `s3_key_prefix` - The key prefix for the specified S3 bucket. Defaults to `null`.<br>    (Optional) `encryption_enabled` - Whether to encrypt query results on S3 bucket.<br>    (Optional) `encryption_mode` - Indicates whether Amazon S3 server-side encryption with Amazon S3-managed keys (SSE\_S3), server-side encryption with KMS-managed keys (SSE\_KMS), or client-side encryption with KMS-managed keys (CSE\_KMS) is used. If a query runs in a workgroup and the workgroup overrides client-side settings, then the workgroup's setting for encryption is used.<br>    (Optional) `encryption_kms_key` - For `SSE_KMS` and `CSE_KMS` encryption modes, this is the KMS key Amazon Resource Name (ARN). | `map(any)` | `null` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the workgroup. |
| <a name="output_client_config_enabled"></a> [client\_config\_enabled](#output\_client\_config\_enabled) | Whether overriding workgroup configurations with client-side configurations is allowed. |
| <a name="output_cloudwatch_metrics_enabled"></a> [cloudwatch\_metrics\_enabled](#output\_cloudwatch\_metrics\_enabled) | Whether Amazon CloudWatch metrics are enabled for the workgroup. |
| <a name="output_description"></a> [description](#output\_description) | The description of the workgroup. |
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Whether to enable the workgroup. |
| <a name="output_force_destroy"></a> [force\_destroy](#output\_force\_destroy) | Whether to delete the workgroup and its contents even if the workgroup contains any named queries. |
| <a name="output_id"></a> [id](#output\_id) | The workgroup name. |
| <a name="output_name"></a> [name](#output\_name) | The name of the workgroup. |
| <a name="output_named_queries"></a> [named\_queries](#output\_named\_queries) | The list of Athena named queries. |
| <a name="output_per_query_data_usage_limit"></a> [per\_query\_data\_usage\_limit](#output\_per\_query\_data\_usage\_limit) | The limit in bytes for the maximum amount of data a query is allowed to scan |
| <a name="output_query_on_s3_requester_pays_bucket_enabled"></a> [query\_on\_s3\_requester\_pays\_bucket\_enabled](#output\_query\_on\_s3\_requester\_pays\_bucket\_enabled) | Whether members assigned to a workgroup to reference Amazon S3 Requester Pays buckets in queries are allowed. |
| <a name="output_query_result"></a> [query\_result](#output\_query\_result) | The configuration for query result location and encryption. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
