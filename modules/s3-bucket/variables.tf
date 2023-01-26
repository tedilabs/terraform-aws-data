variable "name" {
  description = "(Required) Desired name for the S3 bucket."
  type        = string
}

variable "force_destroy" {
  description = "(Optional) A bool that indicates all objects (including any locked objects) should be deleted from the bucket so the bucket can be destroyed without error."
  type        = bool
  default     = false
  nullable    = false
}

variable "encryption" {
  description = <<EOF
  (Optional) A configurations of Server-Side Encryption for the S3 bucket.
    (Optional) `type` - The server-side encryption algorithm to use. Valid values are `AES256` and `AWS_KMS`. Defaults to `AES256`.
    (Optional) `kms_key` - The AWS KMS key ID used for the `SSE-KMS` encryption. This can only be used when you set the value of `encryption.type` as `AWS_KMS`. The default `aws/s3` AWS KMS key is used if this element is absent while the `encryption.type` is `AWS_KMS`.
    (Optional) `bucket_key_enabled` - Whether or not to use Amazon S3 Bucket Keys for SSE-KMS. Defaults to `true`.
  EOF
  type = object({
    type               = optional(string, "AES256")
    kms_key            = optional(string)
    bucket_key_enabled = optional(bool, true)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["AES256", "AWS_KMS"], var.encryption.type)
    error_message = "Valid values for `encryption.type` are `AES256`, `AWS_KMS`."
  }
}

variable "versioning" {
  description = <<EOF
  (Optional) A configurations of Versioning for the S3 bucket.
    (Optional) `status` - A desired status of the bucket versioning. Valid values are `ENABLED`, `SUSPENDED`, or `DISABLED`. Disabled should only be used when creating or importing resources that correspond to unversioned S3 buckets. Defaults to `DISABLED`.
    (Optional) `mfa_deletion` - A configuration for MFA (Multi-factors Authentication) of the bucket versioning on deletion. MFA(multi-factor authentication) configuration on Lifecycle configuration-enabled bucket is not supported. `versioning_mfa_deletion` block as defined below.
      (Optional) `enabled` - Whether MFA delete is enabled in the bucket versioning configuration. Default is `false`.
      (Optional) `device` - The concatenation of the authentication device's serial number, a space, and the value that is displayed on your authentication device.
  EOF
  type = object({
    status = optional(string, "DISABLED")
    mfa_deletion = optional(object({
      enabled = optional(bool, false)
      device  = optional(string, "")
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["ENABLED", "SUSPENDED", "DISABLED"], var.versioning.status)
    error_message = "Valid values for `versioning.status` are `ENABLED`, `SUSPENDED`, `DISABLED`."
  }

  validation {
    condition     = !var.versioning.mfa_deletion.enabled || var.versioning.mfa_deletion.device != ""
    error_message = "`versioning.mfa_deletion.device` is required if `versioning.mfa_deletion.enabled` is `true`."
  }
}

variable "object_lock" {
  description = <<EOF
  (Optional) A configurations of Object Lock for the S3 bucket.
    (Optional) `enabled` - Whether to use an accelerated endpoint for faster data transfers. Defaults to `false`.
    (Optional) `token` - A token to allow Object Lock to be enabled for an existing bucket. You must contact AWS support for the bucket's 'Object Lock token'. The token is generated in the back-end when versioning is enabled on a bucket.
    (Optional) `default_retention` - Specify the default Object Lock retention settings for new objects placed in the bucket. `default_retention` block as defined below.
      (Required) `mode` - The default Object Lock retention mode you want to apply to new objects placed in the specified bucket. Valid values are `COMPLIANCE`, `GOVERNANCE`. Defaults to `GOVERNANCE`.
      (Optional) `unit` - The default Object Lock retention unit. Valid values are `DAYS`, `YEARS`. Defaults to `DAYS`.
      (Optional) `value` - The default Object Lock retention value.
  EOF
  type = object({
    enabled = optional(bool, false)
    token   = optional(string, "")
    default_retention = optional(object({
      mode  = optional(string, "GOVERNANCE")
      unit  = optional(string, "DAYS")
      value = optional(number)
    }))
  })
  default  = {}
  nullable = false

  validation {
    condition = var.object_lock.default_retention == null ? true : (
      alltrue([
        contains(["COMPLIANCE", "GOVERNANCE"], var.object_lock.default_retention.mode),
        contains(["DAYS", "YEARS"], var.object_lock.default_retention.unit),
      ])
    )
    error_message = "Valid values for `object_lock.default_retention.mode` are `COMPLIANCE` and `GOVERNANCE`. Valid values for `object_lock.default_retention.unit are `DAYS` and `YEARS`."
  }
}

variable "lifecycle_rules" {
  description = <<EOF
  (Optional) A configurations of Lifecycle Rules for the S3 bucket. Use lifecycle rules to define actions you want Amazon S3 to take during an object's lifetime such as transitioning objects to another storage class, archiving them, or deleting them after a specified period of time. Each value of `lifecycle_rules` as defined below.
    (Required) `id` - Unique identifier for the rule. The value cannot be longer than 255 characters.
    (Optional) `enabled` - Whether the rule is activated.
    (Optional) `prefix` - The prefix identifying one or more objects to which the rule applies. Defaults to an empty string (`""`) if not specified.
    (Optional) `tags` - A map of tag keys and values to filter.
    (Optional) `min_object_size` - Minimum object size (in bytes) to which the rule applies.
    (Optional) `max_object_size` - Maximum object size (in bytes) to which the rule applies.
    (Optional) `transitions` - A set of configurations to specify when object transitions to a specified storage class.
    (Optional) `noncurrent_version_transitions` - A set of configurations to specify when transitions of noncurrent object versions to a specified storage class.
    (Optional) `expiration` - Configurations to specify the expiration for the lifecycle of the object.
    (Optional) `noncurrent_version_expiration` - Configurations to specify when noncurrent object versions expire.
    (Optional) `abort_incomplete_multipart_upload` - Configurations to specify when S3 will permanently remove all incomplete multipart upload.
  EOF
  type = list(object({
    id      = string
    enabled = optional(bool, true)

    prefix          = optional(string)
    tags            = optional(map(string))
    min_object_size = optional(number)
    max_object_size = optional(number)

    transitions = optional(set(object({
      date = optional(string)
      days = optional(number)

      storage_class = string
    })), [])
    noncurrent_version_transitions = optional(set(object({
      count = optional(number)
      days  = number

      storage_class = string
    })), [])
    expiration = optional(object({
      date = optional(string)
      days = optional(number)

      expired_object_delete_marker = optional(bool, false)
    }))
    noncurrent_version_expiration = optional(object({
      count = optional(number)
      days  = number
    }))
    abort_incomplete_multipart_upload = optional(object({
      days = number
    }))
  }))
  default  = []
  nullable = false
}

variable "policy" {
  description = "(Optional) A valid policy JSON document. Although this is a bucket policy, not an IAM policy, the `aws_iam_policy_document` data source may be used, so long as it specifies a principal. Bucket policies are limited to 20 KB in size."
  type        = string
  default     = null
}

variable "grants" {
  description = <<EOF
  (Optional) A list of the ACL policy grant. Each value of `grants` as defined below.
    (Required) `type` - Valid values are `CanonicalUser` and `Group`. `AmazonCustomerByEmail` is not supported.
    (Required) `permission` - Valid values for `grant.permission` are `READ`, `WRITE`, `READ_ACP`, `WRITE_ACP`, `FULL_CONTROL`.
  EOF
  type = list(object({
    type       = string
    grantee    = string
    permission = string
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for grant in var.grants :
      contains(["CanonicalUser", "Group", "AmazonCustomerByEmail"], grant.type)
    ])
    error_message = "Valid values for `type` are `CanonicalUser`, `Group`, `AmazonCustomerByEmail`."
  }
  validation {
    condition = alltrue([
      for grant in var.grants :
      contains(["READ", "WRITE", "READ_ACP", "WRITE_ACP", "FULL_CONTROL"], grant.permission)
    ])
    error_message = "Valid values for `permission` are `READ`, `WRITE`, `READ_ACP`, `WRITE_ACP`, `FULL_CONTROL`."
  }
}

variable "object_ownership" {
  description = <<EOF
  (Optional) Control ownership of objects written to this bucket from other AWS accounts and granted using access control lists (ACLs). Object ownership determines who can specify access to objects. Valid values: `BucketOwnerPreferred`, `BucketOwnerEnforced` or `ObjectWriter`.
  - `BucketOwnerPreferred`: Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the `bucket-owner-full-control` canned ACL.
  - `ObjectWriter`: The uploading account will own the object if the object is uploaded with the `bucket-owner-full-control` canned ACL.
  - `BucketOwnerEnforced`: The bucket owner automatically owns and has full control over every object in the bucket. ACLs no longer affect permissions to data in the S3 bucket.
  EOF
  type        = string
  default     = "BucketOwnerEnforced"
  nullable    = false

  validation {
    condition     = contains(["BucketOwnerPreferred", "BucketOwnerEnforced", "ObjectWriter"], var.object_ownership)
    error_message = "Valid values for `object_ownership` are `BucketOwnerPreferred`, `BucketOwnerEnforced` or `ObjectWriter`."
  }
}

variable "block_public_access" {
  description = <<EOF
  (Optional) A configurations of Block Public Access for the S3 bucket.
    (Optional) `enabled` - Whether to block all public access to S3 bucket. Defaults to `true`.
    (Optional) `block_public_acls_enabled` - Block new public ACLs and uploading public objects if true. Always enabled if `block_public_access.enabled` is `true`.
    (Optional) `ignore_public_acls_enabled` - Retroactively remove public access granted through public ACLs. Always enabled if `block_public_access.enabled` is `true`.
    (Optional) `block_public_policy_enabled` - Block new public bucket policies. Always enabled if `block_public_access.enabled` is `true`.
    (Optional) `restrict_public_buckets_enabled` - Retroactivley block public and cross-account access if bucket has public policies. Always enabled if `block_public_access.enabled` is `true`.
  EOF
  type = object({
    enabled                         = optional(bool, true)
    block_public_acls_enabled       = optional(bool, false)
    ignore_public_acls_enabled      = optional(bool, false)
    block_public_policy_enabled     = optional(bool, false)
    restrict_public_buckets_enabled = optional(bool, false)
  })
  default  = {}
  nullable = false
}

variable "cors_rules" {
  description = <<EOF
  (Optional) A list of CORS (Cross-Origin Resource Sharing) rules for the bucket. You can configure up to 100 rules. Each value of `cors_rules` as defined below.
    (Optional) `id` - Unique identifier for the rule. The value cannot be longer than 255 characters.
    (Optional) `allowed_headers` - Set of Headers that are specified in the `Access-Control-Request-Headers` header.
    (Required) `allowed_methods` - Set of HTTP methods that you allow the origin to execute. Valid values are `GET`, `PUT`, `HEAD`, `POST`, and `DELETE`.
    (Required) `allowed_origins` - Set of origins you want customers to be able to access the bucket from.
    (Optional) `expose_headers` - Set of headers in the response that you want customers to be able to access from their applications.
    (Optional) `max_age` - The time in seconds that your browser is to cache the preflight response for the specified resource.
  EOF
  type = list(object({
    id              = optional(string)
    allowed_headers = optional(set(string), [])
    allowed_methods = set(string)
    allowed_origins = set(string)
    expose_headers  = optional(set(string), [])
    max_age         = optional(number)
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for rule in var.cors_rules :
      alltrue([
        for method in rule.allowed_methods :
        contains(["GET", "PUT", "HEAD", "POST", "DELETE"], method)
      ])
    ])
    error_message = "Valid values for each value of `allowed_methods` are `GET`, `PUT`, `HEAD`, `POST` or `DELETE`."
  }
}

variable "tls_required" {
  description = "(Optional) Deny any access to the S3 bucket that is not encrypted in-transit if true."
  type        = bool
  default     = true
  nullable    = false
}

variable "logging" {
  description = <<EOF
  (Optional) A configurations of Server Access Logging for the S3 bucket.
    (Optional) `enabled` - Whether to enable S3 bucket logging for the access log. Defaults to `false`.
    (Optional) `s3_bucket` - The name of the bucket to deliver logs to.
    (Optional) `s3_key_prefix` - The key prefix to append to log objects.

    (Optional) `is_target_bucket` - Whether this bucket is the target bucket for Server Access Logging.
    (Optional) `allowed_source_buckets` - A list of names of S3 buckets allowed to write logs to this target bucket. Each source bucket should be owned by same AWS account ID with target bucket. Only used if `is_target_bucket` is `true`.
  EOF
  type = object({
    enabled       = optional(bool, false)
    s3_bucket     = optional(string)
    s3_key_prefix = optional(string)

    is_target_bucket       = optional(bool, false)
    allowed_source_buckets = optional(list(string), [])
  })
  default  = {}
  nullable = false
}

variable "request_metrics" {
  description = <<EOF
  (Optional) A list of CORS (Cross-Origin Resource Sharing) rules for the bucket. You can configure up to 100 rules. Each value of `cors_rules` as defined below.
    (Required) `name` - Unique identifier of the metrics configuration for the bucket. Must be less than or equal to 64 characters in length.
    (Optional) `filter` - Object filtering that accepts a prefix, tags, or a logical AND of prefix and tags. `filter` block as defined below.
      (Optional) `prefix` - Limit this filter to a single prefix.
      (Optional) `tags` - Limit this filter to the key/value pairs. Up to 10 key/value pairs.
  EOF
  type = list(object({
    name = string
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string), {})
    }))
  }))
  default  = []
  nullable = false
}

variable "requester_payment_enabled" {
  description = "(Optional) Whether the requester pays for requests and data transfer costs, and anonymous access to this bucket is disabled. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "transfer_acceleration_enabled" {
  description = "(Optional) Whether to use an accelerated endpoint for faster data transfers."
  type        = bool
  default     = false
  nullable    = false
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module informations."
  type        = bool
  default     = true
  nullable    = false
}


###################################################
# Resource Group
###################################################

variable "resource_group_enabled" {
  description = "(Optional) Whether to create Resource Group to find and group AWS resources which are created by this module."
  type        = bool
  default     = true
  nullable    = false
}

variable "resource_group_name" {
  description = "(Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`."
  type        = string
  default     = ""
  nullable    = false
}

variable "resource_group_description" {
  description = "(Optional) The description of Resource Group."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}
