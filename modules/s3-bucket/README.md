# s3-bucket

This module creates following resources.

- `aws_s3_bucket`
- `aws_s3_bucket_accelerate_configuration`
- `aws_s3_bucket_acl` (optional)
- `aws_s3_bucket_cors_configuration` (optional)
- `aws_s3_bucket_lifecycle_configuration` (optional)
- `aws_s3_bucket_logging` (optional)
- `aws_s3_bucket_metric` (optional)
- `aws_s3_bucket_object_lock_configuration` (optional)
- `aws_s3_bucket_ownership_controls`
- `aws_s3_bucket_policy`
- `aws_s3_bucket_public_access_block`
- `aws_s3_bucket_request_payment_configuration`
- `aws_s3_bucket_server_side_encryption_configuration`
- `aws_s3_bucket_versioning`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.49 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.50.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.10.0 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_accelerate_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_accelerate_configuration) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_metric.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_metric) | resource |
| [aws_s3_bucket_object_lock_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_request_payment_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_request_payment_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_canonical_user_id.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/canonical_user_id) | data source |
| [aws_iam_policy_document.access_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tls_required](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) Desired name for the S3 bucket. | `string` | n/a | yes |
| <a name="input_block_public_access"></a> [block\_public\_access](#input\_block\_public\_access) | (Optional) A configurations of Block Public Access for the S3 bucket.<br>    (Optional) `enabled` - Whether to block all public access to S3 bucket. Defaults to `true`.<br>    (Optional) `block_public_acls_enabled` - Block new public ACLs and uploading public objects if true. Always enabled if `block_public_access.enabled` is `true`.<br>    (Optional) `ignore_public_acls_enabled` - Retroactively remove public access granted through public ACLs. Always enabled if `block_public_access.enabled` is `true`.<br>    (Optional) `block_public_policy_enabled` - Block new public bucket policies. Always enabled if `block_public_access.enabled` is `true`.<br>    (Optional) `restrict_public_buckets_enabled` - Retroactivley block public and cross-account access if bucket has public policies. Always enabled if `block_public_access.enabled` is `true`. | <pre>object({<br>    enabled                         = optional(bool, true)<br>    block_public_acls_enabled       = optional(bool, false)<br>    ignore_public_acls_enabled      = optional(bool, false)<br>    block_public_policy_enabled     = optional(bool, false)<br>    restrict_public_buckets_enabled = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_cors_rules"></a> [cors\_rules](#input\_cors\_rules) | (Optional) A list of CORS (Cross-Origin Resource Sharing) rules for the bucket. You can configure up to 100 rules. Each value of `cors_rules` as defined below.<br>    (Optional) `id` - Unique identifier for the rule. The value cannot be longer than 255 characters.<br>    (Optional) `allowed_headers` - Set of Headers that are specified in the `Access-Control-Request-Headers` header.<br>    (Required) `allowed_methods` - Set of HTTP methods that you allow the origin to execute. Valid values are `GET`, `PUT`, `HEAD`, `POST`, and `DELETE`.<br>    (Required) `allowed_origins` - Set of origins you want customers to be able to access the bucket from.<br>    (Optional) `expose_headers` - Set of headers in the response that you want customers to be able to access from their applications.<br>    (Optional) `max_age` - The time in seconds that your browser is to cache the preflight response for the specified resource. | <pre>list(object({<br>    id              = optional(string)<br>    allowed_headers = optional(set(string), [])<br>    allowed_methods = set(string)<br>    allowed_origins = set(string)<br>    expose_headers  = optional(set(string), [])<br>    max_age         = optional(number)<br>  }))</pre> | `[]` | no |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | (Optional) A configurations of Server-Side Encryption for the S3 bucket.<br>    (Optional) `type` - The server-side encryption algorithm to use. Valid values are `AES256` and `AWS_KMS`. Defaults to `AES256`.<br>    (Optional) `kms_key` - The AWS KMS key ID used for the `SSE-KMS` encryption. This can only be used when you set the value of `encryption.type` as `AWS_KMS`. The default `aws/s3` AWS KMS key is used if this element is absent while the `encryption.type` is `AWS_KMS`.<br>    (Optional) `bucket_key_enabled` - Whether or not to use Amazon S3 Bucket Keys for SSE-KMS. Defaults to `true`. | <pre>object({<br>    type               = optional(string, "AES256")<br>    kms_key            = optional(string)<br>    bucket_key_enabled = optional(bool, true)<br>  })</pre> | `{}` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | (Optional) A bool that indicates all objects (including any locked objects) should be deleted from the bucket so the bucket can be destroyed without error. | `bool` | `false` | no |
| <a name="input_grants"></a> [grants](#input\_grants) | (Optional) A list of the ACL policy grant. Each value of `grants` as defined below.<br>    (Required) `type` - Valid values are `CanonicalUser` and `Group`. `AmazonCustomerByEmail` is not supported.<br>    (Required) `permission` - Valid values for `grant.permission` are `READ`, `WRITE`, `READ_ACP`, `WRITE_ACP`, `FULL_CONTROL`. | <pre>list(object({<br>    type       = string<br>    grantee    = string<br>    permission = string<br>  }))</pre> | `[]` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | (Optional) A configurations of Lifecycle Rules for the S3 bucket. Use lifecycle rules to define actions you want Amazon S3 to take during an object's lifetime such as transitioning objects to another storage class, archiving them, or deleting them after a specified period of time. Each value of `lifecycle_rules` as defined below.<br>    (Required) `id` - Unique identifier for the rule. The value cannot be longer than 255 characters.<br>    (Optional) `enabled` - Whether the rule is activated.<br>    (Optional) `prefix` - The prefix identifying one or more objects to which the rule applies. Defaults to an empty string (`""`) if not specified.<br>    (Optional) `tags` - A map of tag keys and values to filter.<br>    (Optional) `min_object_size` - Minimum object size (in bytes) to which the rule applies.<br>    (Optional) `max_object_size` - Maximum object size (in bytes) to which the rule applies.<br>    (Optional) `transitions` - A set of configurations to specify when object transitions to a specified storage class.<br>    (Optional) `noncurrent_version_transitions` - A set of configurations to specify when transitions of noncurrent object versions to a specified storage class.<br>    (Optional) `expiration` - Configurations to specify the expiration for the lifecycle of the object.<br>    (Optional) `noncurrent_version_expiration` - Configurations to specify when noncurrent object versions expire.<br>    (Optional) `abort_incomplete_multipart_upload` - Configurations to specify when S3 will permanently remove all incomplete multipart upload. | <pre>list(object({<br>    id      = string<br>    enabled = optional(bool, true)<br><br>    prefix          = optional(string)<br>    tags            = optional(map(string))<br>    min_object_size = optional(number)<br>    max_object_size = optional(number)<br><br>    transitions = optional(set(object({<br>      date = optional(string)<br>      days = optional(number)<br><br>      storage_class = string<br>    })), [])<br>    noncurrent_version_transitions = optional(set(object({<br>      count = optional(number)<br>      days  = number<br><br>      storage_class = string<br>    })), [])<br>    expiration = optional(object({<br>      date = optional(string)<br>      days = optional(number)<br><br>      expired_object_delete_marker = optional(bool, false)<br>    }))<br>    noncurrent_version_expiration = optional(object({<br>      count = optional(number)<br>      days  = number<br>    }))<br>    abort_incomplete_multipart_upload = optional(object({<br>      days = number<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | (Optional) A configurations of Server Access Logging for the S3 bucket.<br>    (Optional) `enabled` - Whether to enable S3 bucket logging for the access log. Defaults to `false`.<br>    (Optional) `s3_bucket` - The name of the bucket to deliver logs to.<br>    (Optional) `s3_key_prefix` - The key prefix to append to log objects.<br><br>    (Optional) `is_target_bucket` - Whether this bucket is the target bucket for Server Access Logging.<br>    (Optional) `allowed_source_buckets` - A list of names of S3 buckets allowed to write logs to this target bucket. Each source bucket should be owned by same AWS account ID with target bucket. Only used if `is_target_bucket` is `true`. | <pre>object({<br>    enabled       = optional(bool, false)<br>    s3_bucket     = optional(string)<br>    s3_key_prefix = optional(string)<br><br>    is_target_bucket       = optional(bool, false)<br>    allowed_source_buckets = optional(list(string), [])<br>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_object_lock"></a> [object\_lock](#input\_object\_lock) | (Optional) A configurations of Object Lock for the S3 bucket.<br>    (Optional) `enabled` - Whether to use an accelerated endpoint for faster data transfers. Defaults to `false`.<br>    (Optional) `token` - A token to allow Object Lock to be enabled for an existing bucket. You must contact AWS support for the bucket's 'Object Lock token'. The token is generated in the back-end when versioning is enabled on a bucket.<br>    (Optional) `default_retention` - Specify the default Object Lock retention settings for new objects placed in the bucket. `default_retention` block as defined below.<br>      (Required) `mode` - The default Object Lock retention mode you want to apply to new objects placed in the specified bucket. Valid values are `COMPLIANCE`, `GOVERNANCE`. Defaults to `GOVERNANCE`.<br>      (Optional) `unit` - The default Object Lock retention unit. Valid values are `DAYS`, `YEARS`. Defaults to `DAYS`.<br>      (Optional) `value` - The default Object Lock retention value. | <pre>object({<br>    enabled = optional(bool, false)<br>    token   = optional(string, "")<br>    default_retention = optional(object({<br>      mode  = optional(string, "GOVERNANCE")<br>      unit  = optional(string, "DAYS")<br>      value = optional(number)<br>    }))<br>  })</pre> | `{}` | no |
| <a name="input_object_ownership"></a> [object\_ownership](#input\_object\_ownership) | (Optional) Control ownership of objects written to this bucket from other AWS accounts and granted using access control lists (ACLs). Object ownership determines who can specify access to objects. Valid values: `BucketOwnerPreferred`, `BucketOwnerEnforced` or `ObjectWriter`.<br>  - `BucketOwnerPreferred`: Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the `bucket-owner-full-control` canned ACL.<br>  - `ObjectWriter`: The uploading account will own the object if the object is uploaded with the `bucket-owner-full-control` canned ACL.<br>  - `BucketOwnerEnforced`: The bucket owner automatically owns and has full control over every object in the bucket. ACLs no longer affect permissions to data in the S3 bucket. | `string` | `"BucketOwnerEnforced"` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A valid policy JSON document. Although this is a bucket policy, not an IAM policy, the `aws_iam_policy_document` data source may be used, so long as it specifies a principal. Bucket policies are limited to 20 KB in size. | `string` | `null` | no |
| <a name="input_request_metrics"></a> [request\_metrics](#input\_request\_metrics) | (Optional) A list of CORS (Cross-Origin Resource Sharing) rules for the bucket. You can configure up to 100 rules. Each value of `cors_rules` as defined below.<br>    (Required) `name` - Unique identifier of the metrics configuration for the bucket. Must be less than or equal to 64 characters in length.<br>    (Optional) `filter` - Object filtering that accepts a prefix, tags, or a logical AND of prefix and tags. `filter` block as defined below.<br>      (Optional) `prefix` - Limit this filter to a single prefix.<br>      (Optional) `tags` - Limit this filter to the key/value pairs. Up to 10 key/value pairs. | <pre>list(object({<br>    name = string<br>    filter = optional(object({<br>      prefix = optional(string)<br>      tags   = optional(map(string), {})<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_requester_payment_enabled"></a> [requester\_payment\_enabled](#input\_requester\_payment\_enabled) | (Optional) Whether the requester pays for requests and data transfer costs, and anonymous access to this bucket is disabled. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_tls_required"></a> [tls\_required](#input\_tls\_required) | (Optional) Deny any access to the S3 bucket that is not encrypted in-transit if true. | `bool` | `true` | no |
| <a name="input_transfer_acceleration_enabled"></a> [transfer\_acceleration\_enabled](#input\_transfer\_acceleration\_enabled) | (Optional) Whether to use an accelerated endpoint for faster data transfers. | `bool` | `false` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | (Optional) A configurations of Versioning for the S3 bucket.<br>    (Optional) `status` - A desired status of the bucket versioning. Valid values are `ENABLED`, `SUSPENDED`, or `DISABLED`. Disabled should only be used when creating or importing resources that correspond to unversioned S3 buckets. Defaults to `DISABLED`.<br>    (Optional) `mfa_deletion` - A configuration for MFA (Multi-factors Authentication) of the bucket versioning on deletion. MFA(multi-factor authentication) configuration on Lifecycle configuration-enabled bucket is not supported. `versioning_mfa_deletion` block as defined below.<br>      (Optional) `enabled` - Whether MFA delete is enabled in the bucket versioning configuration. Default is `false`.<br>      (Optional) `device` - The concatenation of the authentication device's serial number, a space, and the value that is displayed on your authentication device. | <pre>object({<br>    status = optional(string, "DISABLED")<br>    mfa_deletion = optional(object({<br>      enabled = optional(bool, false)<br>      device  = optional(string, "")<br>    }), {})<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_control"></a> [access\_control](#output\_access\_control) | The configuration for the S3 bucket access control. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the bucket. |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | The bucket domain name. Will be of format `bucketname.s3.amazonaws.com`. |
| <a name="output_encryption"></a> [encryption](#output\_encryption) | The configuration for the S3 bucket Server-Side Encryption. |
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | The Route 53 Hosted Zone ID for this bucket's region. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the bucket. |
| <a name="output_lifecycle_rules"></a> [lifecycle\_rules](#output\_lifecycle\_rules) | The lifecycle configuration for the bucket. |
| <a name="output_logging"></a> [logging](#output\_logging) | The logging configuration for the bucket. |
| <a name="output_monitoring"></a> [monitoring](#output\_monitoring) | The monitoring configuration for the bucket. |
| <a name="output_name"></a> [name](#output\_name) | The name of the bucket. |
| <a name="output_object_lock"></a> [object\_lock](#output\_object\_lock) | The configuration for the S3 Object Lock of the bucket. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this bucket resides in. |
| <a name="output_regional_domain_name"></a> [regional\_domain\_name](#output\_regional\_domain\_name) | The bucket region-specific domain name. The bucket domain name including the region name. |
| <a name="output_requester_payment"></a> [requester\_payment](#output\_requester\_payment) | The configuration for the S3 bucket request payment. |
| <a name="output_transfer_acceleration"></a> [transfer\_acceleration](#output\_transfer\_acceleration) | The configuration for the S3 Transfer Acceleration of the bucket. |
| <a name="output_versioning"></a> [versioning](#output\_versioning) | The versioning configuration for the bucket. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
