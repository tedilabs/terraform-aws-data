# athena-workgroup

This module creates following resources.

- `aws_athena_workgroup`
- `aws_athena_named_query` (optional)
- `aws_athena_prepared_statement` (optional)

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
| <a name="module_role__iam_identity_center"></a> [role\_\_iam\_identity\_center](#module\_role\_\_iam\_identity\_center) | tedilabs/account/aws//modules/iam-role | ~> 0.33.0 |

## Resources

| Name | Type |
|------|------|
| [aws_athena_named_query.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query) | resource |
| [aws_athena_prepared_statement.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_prepared_statement) | resource |
| [aws_athena_workgroup.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_workgroup) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.iam_identity_center](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssoadmin_instances.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the workgroup. | `string` | n/a | yes |
| <a name="input_analytics_engine"></a> [analytics\_engine](#input\_analytics\_engine) | (Optional) The configuration for the Athena engine version. An `analytics_engine` block as defined below.<br/>    (Optional) `version` - The engine version for the workgroup. Valid values are `AUTO`, `ATHENA_V3`, `PYSPARK_V3` and `SPARK_V3.5`. Defaults to `AUTO`. | <pre>object({<br/>    version = optional(string, "AUTO")<br/>  })</pre> | `{}` | no |
| <a name="input_cloudwatch_metrics_enabled"></a> [cloudwatch\_metrics\_enabled](#input\_cloudwatch\_metrics\_enabled) | (Optional) Whether Amazon CloudWatch metrics are enabled for the workgroup. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) The description of the workgroup. Defaults to `Managed by Terraform.`. | `string` | `"Managed by Terraform."` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | (Optional) Whether to enable the workgroup. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | (Optional) Whether to delete the workgroup and its contents even if the workgroup contains any named queries. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_iam_identity_center"></a> [iam\_identity\_center](#input\_iam\_identity\_center) | (Optional) The configuration for IAM Identity Center authentication. An `iam_identity_center` block as defined below.<br/>    (Optional) `enabled` - Whether to enable IAM Identity Center authentication for the workgroup. Defaults to `false`.<br/>    (Optional) `instance` - The Amazon Resource Name (ARN) of the IAM Identity Center instance to use for authentication.<br/>    (Optional) `default_service_role` - A configurations for default IAM Role to be used by workgroup members authenticated via IAM Identity Center. Use `service_role` if `default_service_role.enabled` is `false`. `default_service_role` as defined below.<br/>      (Optional) `enabled` - Whether to create default IAM Role for workgroup members authenticated via IAM Identity Center. Defaults to `true`.<br/>      (Optional) `name` - The name of the IAM Role. If not provided, a name will be generated using the module name and instance name.<br/>      (Optional) `path` - The path for the IAM Role. Defaults to `/`.<br/>      (Optional) `description` - The description of the IAM Role. Defaults to `Managed by Terraform.`.<br/>      (Optional) `policies` - A list of IAM Policy ARNs to attach to the IAM Role. Defaults to an empty list.<br/>      (Optional) `inline_policies` - A map of names to inline policy documents to attach to the IAM Role. Defaults to an empty map.<br/>    (Optional) `service_role` - The Amazon Resource Name (ARN) of the IAM Role to be used by workgroup members authenticated via IAM Identity Center. Only required if `default_service_role.enabled` is `false`. | <pre>object({<br/>    enabled  = optional(bool, false)<br/>    instance = optional(string)<br/>    default_service_role = optional(object({<br/>      enabled         = optional(bool, true)<br/>      name            = optional(string)<br/>      path            = optional(string, "/")<br/>      description     = optional(string, "Managed by Terraform.")<br/>      policies        = optional(list(string), [])<br/>      inline_policies = optional(map(string), {})<br/>    }), {})<br/>    service_role = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_named_queries"></a> [named\_queries](#input\_named\_queries) | (Optional) A list of named queries to reuse later. A `named_queries` block as defined below.<br/>    (Required) `name` - The plain language name for the query. Maximum length of 128.<br/>    (Optional) `description` - A brief explanation of the query. Defaults to `Managed by Terraform.`.<br/>    (Required) `database` - The database to which the query belongs.<br/>    (Required) `query` - The text of the query itself. In other words, all query statements. Maximum length of 262144. | <pre>list(object({<br/>    name        = string<br/>    description = optional(string, "Managed by Terraform.")<br/><br/>    database = string<br/>    query    = string<br/>  }))</pre> | `[]` | no |
| <a name="input_per_query_data_usage_limit"></a> [per\_query\_data\_usage\_limit](#input\_per\_query\_data\_usage\_limit) | (Optional) Sets the limit in bytes for the maximum amount of data a query is allowed to scan. You can set only one per query limit for a workgroup. The limit applies to all queries in the workgroup and if query exceeds the limit, it will be cancelled. Minimum limit is 10 MB and maximum limit is 7EB per workgroup. | `number` | `null` | no |
| <a name="input_prepared_statements"></a> [prepared\_statements](#input\_prepared\_statements) | (Optional) A list of prepared statements to reuse later. A `prepared_statements` block as defined below.<br/>    (Required) `name` - The name of the prepared statement. Maximum length of 256.<br/>    (Optional) `description` - A brief explanation of the prepared statements. Defaults to `Managed by Terraform.`.<br/>    (Required) `query` - The query string for the prepared statement. | <pre>list(object({<br/>    name        = string<br/>    description = optional(string, "Managed by Terraform.")<br/><br/>    query = string<br/>  }))</pre> | `[]` | no |
| <a name="input_query_on_s3_requester_pays_bucket_enabled"></a> [query\_on\_s3\_requester\_pays\_bucket\_enabled](#input\_query\_on\_s3\_requester\_pays\_bucket\_enabled) | (Optional) Whether to allow members assigned to a workgroup to reference Amazon S3 Requester Pays buckets in queries. If set to false, workgroup members cannot query data from Requester Pays buckets, and queries that retrieve data from Requester Pays buckets cause an error. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_query_result"></a> [query\_result](#input\_query\_result) | (Optional) The configuration for query result location and encryption. Only required if you use Apache Spark engine types. `query_result` block as defined below.<br/>    (Optional) `management_mode` - The mode of query result management. Valid values are `CUSTOMER_MANAGED` and `ATHENA_MANAGED`. Defaults to `ATHENA_MANAGED`.<br/>      `CUSTOMER_MANAGED` - You manage the storage for your query results and keep the results as long as you require.<br/>      `ATHENA_MANAGED` - Athena manages the storage for your queries and retains query results for 24 hours.<br/>    (Optional) `override_client_config` - Whether to override client-side settings. Defaults to `true`.<br/>    (Optional) `athena_managed_query_result` - A configurations for Athena managed query result. `athena_managed_query_result` as defined below.<br/>      (Optional) `encryption` - A configurations for encryption of Athena managed query result. `encryption` as defined below.<br/>        (Optional) `kms_key` - The KMS key Amazon Resource Name (ARN) used to encrypt the query results.<br/>    (Optional) `customer_managed_query_result` - A configurations for Customer managed query result. `customer_managed_query_result` as defined below.<br/>      (Optional) `s3_bucket` - A configurations for S3 bucket used to store the query result. `s3_bucket` as defined below.<br/>        (Required) `name` - The name of the S3 bucket used to store the query result.<br/>        (Optional) `key_prefix` - The key prefix for the specified S3 bucket.<br/>        (Optional) `expected_bucket_owner` - The AWS account ID that you expect to be the owner of the Amazon S3 bucket.<br/>        (Optional) `bucket_owner_full_control_enabled` - Whether to grant the owner of the S3 query results bucket full control over the query results. This means that if your query result location is owned by another account, you grant full control over your query results to the other account. Defaults to `false`.<br/>      (Optional) `encryption` - A configurations for encryption of Customer managed query result. `encryption` as defined below.<br/>        (Optional) `enabled` - Whether to encrypt query results on S3 bucket. Defaults to `false`.<br/>        (Optional) `mode` - The encryption mode to use. Valid values are `SSE_S3`, `SSE_KMS` and `CSE_KMS`. Defaults to `SSE_S3`.<br/>          `SSE_S3` - Server-side encryption with Amazon S3-managed keys.<br/>          `SSE_KMS` - Server-side encryption with KMS-managed keys.<br/>          `CSE_KMS` - Client-side encryption with KMS-managed keys.<br/>        (Optional) `kms_key` - The KMS key Amazon Resource Name (ARN) used to encrypt the query results. Required if `mode` is set to `SSE_KMS` or `CSE_KMS`. | <pre>object({<br/>    management_mode        = optional(string, "ATHENA_MANAGED")<br/>    override_client_config = optional(bool, true)<br/>    athena_managed_query_result = optional(object({<br/>      encryption = optional(object({<br/>        kms_key = optional(string, null)<br/>      }), {})<br/>    }), {})<br/>    customer_managed_query_result = optional(object({<br/>      s3_bucket = object({<br/>        name                              = string<br/>        key_prefix                        = optional(string, "")<br/>        expected_bucket_owner             = optional(string)<br/>        bucket_owner_full_control_enabled = optional(bool, false)<br/>      })<br/>      encryption = optional(object({<br/>        enabled = optional(bool, false)<br/>        mode    = optional(string, "SSE_S3")<br/>        kms_key = optional(string, null)<br/>      }), {})<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_analytics_engine"></a> [analytics\_engine](#output\_analytics\_engine) | The configuration for the Athena engine version. |
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the workgroup. |
| <a name="output_cloudwatch_metrics_enabled"></a> [cloudwatch\_metrics\_enabled](#output\_cloudwatch\_metrics\_enabled) | Whether Amazon CloudWatch metrics are enabled for the workgroup. |
| <a name="output_description"></a> [description](#output\_description) | The description of the workgroup. |
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Whether to enable the workgroup. |
| <a name="output_force_destroy"></a> [force\_destroy](#output\_force\_destroy) | Whether to delete the workgroup and its contents even if the workgroup contains any named queries. |
| <a name="output_iam_identity_center"></a> [iam\_identity\_center](#output\_iam\_identity\_center) | The configuration for query result location and encryption. |
| <a name="output_id"></a> [id](#output\_id) | The workgroup name. |
| <a name="output_name"></a> [name](#output\_name) | The name of the workgroup. |
| <a name="output_named_queries"></a> [named\_queries](#output\_named\_queries) | The list of Athena named queries. |
| <a name="output_per_query_data_usage_limit"></a> [per\_query\_data\_usage\_limit](#output\_per\_query\_data\_usage\_limit) | The limit in bytes for the maximum amount of data a query is allowed to scan |
| <a name="output_prepared_statements"></a> [prepared\_statements](#output\_prepared\_statements) | The list of Athena prepared statements. |
| <a name="output_query_on_s3_requester_pays_bucket_enabled"></a> [query\_on\_s3\_requester\_pays\_bucket\_enabled](#output\_query\_on\_s3\_requester\_pays\_bucket\_enabled) | Whether members assigned to a workgroup to reference Amazon S3 Requester Pays buckets in queries are allowed. |
| <a name="output_query_result"></a> [query\_result](#output\_query\_result) | The configuration for query result location and encryption. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
<!-- END_TF_DOCS -->
