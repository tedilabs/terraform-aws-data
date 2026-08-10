# s3-table-bucket

This module creates following resources.

- `aws_s3tables_table_bucket`
- `aws_s3tables_namespace` (optional)
- `aws_s3tables_table_bucket_policy` (optional)
- `aws_s3tables_table_bucket_replication` (optional)

## Notes

- The integration with AWS Glue Data Catalog and AWS Lake Formation (`s3tablescatalog` federated catalog) is not supported by Terraform yet. Enable the integration manually via the AWS console or `aws glue create-catalog` CLI command.
- `force_destroy` requires a successful `terraform apply` run after it is set to `true` before it takes effect on a destroy operation. Tables and namespaces deleted by `force_destroy` are not recoverable.
- `policy` determines whether to create the policy resource, so it must be known at plan time. Avoid interpolating values that are unknown until apply (e.g. generated bucket names) in the policy document. Use `*` to refer to the resources the policy is attached to instead.
- The replication configuration is a singleton per table bucket. The service currently supports only one rule per replication configuration, and each rule supports up to 5 destinations. The default service role only includes `s3tables` permissions — add KMS permissions with `replication.default_service_role.policies` or `inline_policies` if the tables are encrypted with KMS.

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
| <a name="module_replication_service_role"></a> [replication\_service\_role](#module\_replication\_service\_role) | tedilabs/account/aws//modules/iam-role | ~> 0.32.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.12.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_s3tables_namespace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3tables_namespace) | resource |
| [aws_s3tables_table_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3tables_table_bucket) | resource |
| [aws_s3tables_table_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3tables_table_bucket_policy) | resource |
| [aws_s3tables_table_bucket_replication.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3tables_table_bucket_replication) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | (Required) Desired name for the S3 table bucket. Must be between 3 and 63 characters in length. Can consist of lowercase letters, numbers, and hyphens, and must begin and end with a lowercase letter or number. | `string` | n/a | yes |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | (Optional) A configurations of Server-Side Encryption for the S3 table bucket. `encryption` as defined below.<br/>    (Optional) `type` - The server-side encryption algorithm to use. Valid values are `AES256` and `AWS_KMS`. Defaults to `AES256`.<br/>    (Optional) `kms_key` - The ARN of the AWS KMS key used for the `SSE-KMS` encryption. This can only be used when you set the value of `encryption.type` as `AWS_KMS`. | <pre>object({<br/>    type    = optional(string, "AES256")<br/>    kms_key = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | (Optional) A bool that indicates all tables and namespaces within the table bucket should be deleted when the table bucket is destroyed so that the table bucket can be destroyed without error. These tables and namespaces are not recoverable. A successful `terraform apply` run is required after this parameter is set to `true` before it takes effect on a destroy operation. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_maintenance"></a> [maintenance](#input\_maintenance) | (Optional) A configurations of maintenance for the S3 table bucket. If not provided, the maintenance configuration is fully managed by AWS with the service default values. `maintenance` as defined below.<br/>    (Optional) `unreferenced_file_removal` - A configuration for the unreferenced file removal maintenance, which deletes objects that are not referenced by any table snapshot. `unreferenced_file_removal` as defined below.<br/>      (Optional) `enabled` - Whether the unreferenced file removal maintenance is enabled. Defaults to `true`.<br/>      (Required) `unreferenced_days` - The number of days an object must be unreferenced by the table before it is marked for deletion. Must be at least `1`.<br/>      (Required) `non_current_days` - The number of days an object marked for deletion can be noncurrent before it is deleted. Must be at least `1`. | <pre>object({<br/>    unreferenced_file_removal = optional(object({<br/>      enabled           = optional(bool, true)<br/>      unreferenced_days = number<br/>      non_current_days  = number<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_namespaces"></a> [namespaces](#input\_namespaces) | (Optional) A set of names of namespaces to create in the S3 table bucket. Namespaces are used to logically group tables in the table bucket. Each name must be between 1 and 255 characters in length, can consist of lowercase letters, numbers, and underscores, and must begin and end with a lowercase letter or number. | `set(string)` | `[]` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A valid resource policy JSON document for the S3 table bucket. Although this is a table bucket policy, not an IAM policy, the `aws_iam_policy_document` data source may be used, so long as it specifies a principal. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_replication"></a> [replication](#input\_replication) | (Optional) A configurations of Replication for the S3 table bucket. Replication applies to all tables in the source table bucket. `replication` as defined below.<br/>    (Optional) `rules` - A list of replication rules. The service currently supports only one rule per replication configuration. Each value of `rules` as defined below.<br/>      (Required) `destinations` - A set of ARNs of the destination table buckets to replicate source tables to. Each rule supports up to 5 destinations.<br/>    (Optional) `service_role` - The ARN (Amazon Resource Name) of the IAM Role that Amazon S3 assumes when replicating tables. Only required if `replication.default_service_role.enabled` is `false`.<br/>    (Optional) `default_service_role` - A configuration for the default service role for the table bucket replication. Use `replication.service_role` if `replication.default_service_role.enabled` is `false`. Add KMS permissions with `policies` or `inline_policies` if the tables are encrypted with KMS. `default_service_role` as defined below.<br/>      (Optional) `enabled` - Whether to create the default service role. Defaults to `true`.<br/>      (Optional) `name` - The name of the default service role. Defaults to `s3tables-${var.name}-replication`.<br/>      (Optional) `path` - The path of the default service role. Defaults to `/`.<br/>      (Optional) `description` - The description of the default service role.<br/>      (Optional) `policies` - A list of IAM policy ARNs to attach to the default service role. Defaults to `[]`.<br/>      (Optional) `inline_policies` - A Map of inline IAM policies to attach to the default service role. (`name` => `policy`).<br/>      (Optional) `permissions_boundary` - The ARN of the IAM policy to use as permissions boundary for the default service role. | <pre>object({<br/>    rules = optional(list(object({<br/>      destinations = set(string)<br/>    })), [])<br/><br/>    service_role = optional(string)<br/>    default_service_role = optional(object({<br/>      enabled     = optional(bool, true)<br/>      name        = optional(string)<br/>      path        = optional(string, "/")<br/>      description = optional(string, "Managed by Terraform.")<br/><br/>      policies             = optional(list(string), [])<br/>      inline_policies      = optional(map(string), {})<br/>      permissions_boundary = optional(string)<br/>    }), {})<br/>  })</pre> | `{}` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the table bucket. |
| <a name="output_created_at"></a> [created\_at](#output\_created\_at) | Date and time when the table bucket was created. |
| <a name="output_encryption"></a> [encryption](#output\_encryption) | The configuration for the Server-Side Encryption of the table bucket. |
| <a name="output_maintenance"></a> [maintenance](#output\_maintenance) | The maintenance configuration of the table bucket. |
| <a name="output_name"></a> [name](#output\_name) | The name of the table bucket. |
| <a name="output_namespaces"></a> [namespaces](#output\_namespaces) | The namespaces created in the table bucket. |
| <a name="output_owner"></a> [owner](#output\_owner) | The account ID of the account that owns the table bucket. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_replication"></a> [replication](#output\_replication) | The replication configuration of the table bucket. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
<!-- END_TF_DOCS -->
