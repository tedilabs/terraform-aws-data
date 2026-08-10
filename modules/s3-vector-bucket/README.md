# s3-vector-bucket

This module creates following resources.

- `aws_s3vectors_vector_bucket`
- `aws_s3vectors_index` (optional)
- `aws_s3vectors_vector_bucket_policy` (optional)

## Notes

- All arguments of a vector index force a new resource to be created when changed. The vectors stored in the index are **not recoverable** and need to be re-embedded and re-ingested.
- The encryption configuration of the vector bucket forces a new vector bucket to be created when changed. Decide the KMS key before creating the bucket.
- Vector data plane operations (`PutVectors`, `QueryVectors`, ...) are not managed by Terraform. Use AWS SDKs in your application.
- `force_destroy` requires a successful `terraform apply` run after it is set to `true` before it takes effect on a destroy operation.
- `policy` determines whether to create the policy resource, so it must be known at plan time. Avoid interpolating values that are unknown until apply (e.g. generated bucket names) in the policy document. Use `*` to refer to the resources the policy is attached to instead.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.57 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.57.1 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.12.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_s3vectors_index.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3vectors_index) | resource |
| [aws_s3vectors_vector_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3vectors_vector_bucket) | resource |
| [aws_s3vectors_vector_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3vectors_vector_bucket_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | (Required) Desired name for the S3 vector bucket. Must be between 3 and 63 characters in length. Can consist of lowercase letters, numbers, and hyphens, and must begin and end with a lowercase letter or number. | `string` | n/a | yes |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | (Optional) A configurations of Server-Side Encryption for the S3 vector bucket. Changing this forces a new vector bucket to be created. `encryption` as defined below.<br/>    (Optional) `type` - The server-side encryption type to use. Valid values are `AES256` and `AWS_KMS`. Defaults to `AES256`.<br/>    (Optional) `kms_key` - The ARN of the AWS KMS key used for the `SSE-KMS` encryption. This can only be used when you set the value of `encryption.type` as `AWS_KMS`. | <pre>object({<br/>    type    = optional(string, "AES256")<br/>    kms_key = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | (Optional) A bool that indicates all indexes and vectors should be deleted from the vector bucket when the vector bucket is destroyed so that the vector bucket can be destroyed without error. A successful `terraform apply` run is required after this parameter is set to `true` before it takes effect on a destroy operation. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_indexes"></a> [indexes](#input\_indexes) | (Optional) A list of vector indexes to create in the S3 vector bucket. A vector index is used to organize and logically group vector data. All arguments of a vector index force a new resource to be created when changed, and the vectors stored in the index are not recoverable. Each value of `indexes` as defined below.<br/>    (Required) `name` - The name of the vector index. The name must be unique within `indexes`.<br/>    (Required) `dimension` - The dimensions of the vectors to be inserted into the vector index. Must be between `1` and `4096`.<br/>    (Optional) `distance_metric` - The distance metric to be used for similarity search. Valid values are `cosine` and `euclidean`. Defaults to `cosine`.<br/>    (Optional) `data_type` - The data type of the vectors to be inserted into the vector index. Only `float32` is supported. Defaults to `float32`.<br/>    (Optional) `encryption` - A configuration of Server-Side Encryption for the vector index. If not provided, the encryption configuration of the vector bucket is used. `encryption` as defined below.<br/>      (Optional) `type` - The server-side encryption type to use. Valid values are `AES256` and `AWS_KMS`. Defaults to `AES256`.<br/>      (Optional) `kms_key` - The ARN of the AWS KMS key used for the `SSE-KMS` encryption. This can only be used when you set the value of `encryption.type` as `AWS_KMS`.<br/>    (Optional) `metadata` - A configuration of the metadata for the vector index. `metadata` as defined below.<br/>      (Optional) `non_filterable_keys` - A set of metadata keys that cannot be used as query filters. Non-filterable metadata is only returned with query results.<br/>    (Optional) `tags` - A map of tags to add to the vector index. | <pre>list(object({<br/>    name = string<br/><br/>    dimension       = number<br/>    distance_metric = optional(string, "cosine")<br/>    data_type       = optional(string, "float32")<br/><br/>    encryption = optional(object({<br/>      type    = optional(string, "AES256")<br/>      kms_key = optional(string)<br/>    }))<br/>    metadata = optional(object({<br/>      non_filterable_keys = optional(set(string), [])<br/>    }), {})<br/><br/>    tags = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A valid resource policy JSON document for the S3 vector bucket. Although this is a vector bucket policy, not an IAM policy, the `aws_iam_policy_document` data source may be used, so long as it specifies a principal. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the vector bucket. |
| <a name="output_created_at"></a> [created\_at](#output\_created\_at) | Date and time when the vector bucket was created. |
| <a name="output_encryption"></a> [encryption](#output\_encryption) | The configuration for the Server-Side Encryption of the vector bucket. |
| <a name="output_indexes"></a> [indexes](#output\_indexes) | The vector indexes created in the vector bucket. |
| <a name="output_name"></a> [name](#output\_name) | The name of the vector bucket. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
<!-- END_TF_DOCS -->
