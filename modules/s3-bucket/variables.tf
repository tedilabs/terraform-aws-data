variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) Desired name for the S3 bucket."
  type        = string
  nullable    = false
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
    (Optional) `kms_key` - The AWS KMS key ID used for the `SSE-KMS` encryption. This can only be used when you set the value of `encryption.type` as `AWS_KMS` or `AWS_KMS_DSSE`. The default `aws/s3` AWS KMS key is used if this element is absent while the `encryption.type` is `AWS_KMS` or `AWS_KMS_DSSE`.
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
    condition     = contains(["AES256", "AWS_KMS", "AWS_KMS_DSSE"], var.encryption.type)
    error_message = "Valid values for `encryption.type` are `AES256`, `AWS_KMS`, `AWS_KMS_DSSE`."
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
    (Optional) `default_retention` - Specify the default Object Lock retention settings for new objects placed in the bucket. `default_retention` block as defined below.
      (Required) `mode` - The default Object Lock retention mode you want to apply to new objects placed in the specified bucket. Valid values are `COMPLIANCE`, `GOVERNANCE`. Defaults to `GOVERNANCE`.
      (Optional) `unit` - The default Object Lock retention unit. Valid values are `DAYS`, `YEARS`. Defaults to `DAYS`.
      (Optional) `value` - The default Object Lock retention value.
  EOF
  type = object({
    enabled = optional(bool, false)
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

variable "lifecycle_transition_default_min_object_size_strategy" {
  description = "(Optional) The default minimum object size (in bytes) to which the lifecycle transition rule applies. This is used when a lifecycle rule does not specify `min_object_size`. Valid values are `all_storage_classes_128K` and `varies_by_storage_class`. Custom filters always take precedence over the default transition behavior. Defaults to `all_storage_classes_128K`."
  type        = string
  default     = "all_storage_classes_128K"
  nullable    = false

  validation {
    condition     = contains(["all_storage_classes_128K", "varies_by_storage_class"], var.lifecycle_transition_default_min_object_size_strategy)
    error_message = "Valid values for `lifecycle_transition_default_min_object_size_strategy` are `all_storage_classes_128K` and `varies_by_storage_class`."
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

    prefix          = optional(string, "")
    tags            = optional(map(string), {})
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

variable "replication_iam_role" {
  description = <<EOF
  (Optional) The ARN (Amazon Resource Name) of the IAM Role that Amazon S3 assumes when replicating objects. Only required if `default_replication_iam_role.enabled` is `false`.
  EOF
  type        = string
  default     = null
  nullable    = true
}

variable "default_replication_iam_role" {
  description = <<EOF
  (Optional) A configuration for the default IAM role for the S3 bucket replication. Use `replication_iam_role` if `default_replication_iam_role.enabled` is `false`. `default_replication_iam_role` as defined below.
    (Optional) `enabled` - Whether to create the default replication IAM role. Defaults to `true`.
    (Optional) `name` - The name of the default replication IAM role. Defaults to `s3-$${var.name}-replication`.
    (Optional) `path` - The path of the default replication IAM role. Defaults to `/`.
    (Optional) `description` - The description of the default replication IAM role.
    (Optional) `policies` - A list of IAM policy ARNs to attach to the default replication IAM role. Defaults to `[]`.
    (Optional) `inline_policies` - A Map of inline IAM policies to attach to the default replication IAM role. (`name` => `policy`).
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string)
    path        = optional(string, "/")
    description = optional(string, "Managed by Terraform.")

    policies        = optional(list(string), [])
    inline_policies = optional(map(string), {})
  })
  default  = {}
  nullable = false
}

variable "replication_rules" {
  description = <<EOF
  (Optional) A configurations of Replication Rules for the S3 bucket. Use replication rules to define actions for automatic replication of objects across different AWS Regions or within the same Region. Each value of `replication_rules` as defined below.
    (Required) `id` - Unique identifier for the rule. Must be less than or equal to 255 characters in length.
    (Optional) `priority` - The priority associated with the rule. Priority must be unique across all replication rules. Defaults to `0`.
    (Optional) `enabled` - Whether the rule is activated. Defaults to `true`.
    (Optional) `prefix` - The prefix identifying one or more objects to which the rule applies. Defaults to an empty string (`""`) if not specified.
    (Optional) `tags` - A map of tag keys and values to filter objects for replication.
    (Required) `destination` - A configuration of replication destination. `destination` block as defined below.
      (Required) `bucket` - The destination S3 bucket name.
      (Optional) `account` - The account ID of the destination bucket owner. Defaults to current account.
      (Optional) `storage_class` - The storage class to use when replicating objects. By default, Amazon S3 uses the storage class of the source object to create the object replica.
    (Optional) `ownership_translation_enabled` - Whether to enable ownership translation. Ownership translation is required when you are replicating objects to a destination bucket owned by a different AWS account. Defaults to `false`.
    (Optional) `replication_time` - A configuration for S3 Replication Time Control (S3 RTC). `replication_time` block as defined below.
      (Required) `enabled` - Whether S3 Replication Time Control is enabled.
      (Optional) `minutes` - The time in minutes by which replication should be completed. Valid value is `15`.
    (Optional) `metrics` - A configuration for replication metrics. With replication metrics, you can monitor the total number and size of objects that are pending replication, and the maximum replication time to the destination Region. You can also view and diagnose replication failures. CloudWatch metrics fees apply. `metrics` block as defined below.
      (Required) `enabled` - Whether replication metrics are enabled. Defaults to `false`.
      (Optional) `time_threshold` - The time threshold in minutes for emitting the `s3:Replication:OperationMissedThreshold` event. Valid value is `15`.
    (Optional) `delete_marker_replication_enabled` - Whether to replicate delete markers. Delete markers created by S3 delete operations will be replicated. Delete markers created by lifecycle rules are not replicated. Defaults to `false`.
    (Optional) `replica_modification_sync_enabled` - Whether to enable replica modification sync. S3 replica modification sync can help you keep object metadata such as tags, access control lists (ACLs), and Object Lock settings replicated between replicas and source objects. By default, Amazon S3 replicates metadata from the source objects to the replicas only. When replica modification sync is enabled, Amazon S3 replicates metadata changes made to the replica copies back to the source object, making the replication bidirectional. Defaults to `false`.
    (Optional) `sse_kms_encrypted_objects_replication` - A configuration to replicate objects encrypted with AWS KMS. `sse_kms_encrypted_objects_replication` block as defined below.
      (Optional) `enabled` - Whether to replicate objects encrypted with AWS KMS. Defaults to `false`.
      (Optional) `kms_key` - The AWS KMS key ID (Key ARN or Alias ARN) used to encrypt the replica object for the destination bucket.
  EOF
  type = list(object({
    id       = string
    priority = optional(number, 0)
    enabled  = optional(bool, true)

    prefix = optional(string, "")
    tags   = optional(map(string), {})

    destination = object({
      bucket  = string
      account = optional(string)

      storage_class = optional(string)
    })

    ownership_translation_enabled     = optional(bool, false)
    delete_marker_replication_enabled = optional(bool, false)
    replica_modification_sync_enabled = optional(bool, false)
    replication_time_control = optional(object({
      enabled        = optional(bool, false)
      time_threshold = optional(number, 15)
    }), {})
    metrics = optional(object({
      enabled        = optional(bool, false)
      time_threshold = optional(number, 15)
    }), {})
    sse_kms_encrypted_objects_replication = optional(object({
      enabled = optional(bool, false)
      kms_key = optional(string)
    }), {})
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for rule in var.replication_rules :
      length(rule.id) <= 255
    ])
    error_message = "The replication rule ID must be less than or equal to 255 characters in length."
  }
  validation {
    condition = alltrue([
      for rule in var.replication_rules :
      rule.metrics.enabled
      if rule.replication_time_control.enabled
    ])
    error_message = "`metrics.enabled` must be `true` if `replication_time_control.enabled` is `true`."
  }
  validation {
    condition = alltrue([
      for rule in var.replication_rules :
      !rule.delete_marker_replication_enabled
      if length(rule.tags) > 0
    ])
    error_message = "`delete_marker_replication_enabled` must be `false` if `tags` are set."
  }
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
    (Optional) `s3_key_format` - The key format to use for log object keys. Valid values are `SIMPLE`, `PARTITIONED_BY_DELIVERY_TIME` and `PARTITIONED_BY_EVENT_TIME`. Defaults to `SIMPLE`.
      `SIMPLE` - The key is in the format `[s3_key_prefix][YYYY]-[MM]-[DD]-[hh]-[mm]-[ss]-[UniqueString]`.
      `PARTITIONED_BY_DELIVERY_TIME` - The key is in the format `[s3_key_prefix][SourceAccountId]/[SourceRegion]/[SourceBucket]/[YYYY]/[MM]/[DD]/[YYYY]-[MM]-[DD]-[hh]-[mm]-[ss]-[UniqueString]`. The time in the log file names corresponds to the delivery time for the log files.
      `PARTITIONED_BY_EVENT_TIME` - The key is in the format `[s3_key_prefix][SourceAccountId]/[SourceRegion]/[SourceBucket]/[YYYY]/[MM]/[DD]/[YYYY]-[MM]-[DD]-[hh]-[mm]-[ss]-[UniqueString]`. The year, month, and day correspond to the day on which the event occurred, and the hour, minutes and seconds are set to 00 in the key.
    (Optional) `is_target_bucket` - Whether this bucket is the target bucket for Server Access Logging.
    (Optional) `allowed_source_buckets` - A list of names of S3 buckets allowed to write logs to this target bucket. Each source bucket should be owned by same AWS account ID with target bucket. Only used if `is_target_bucket` is `true`.
  EOF
  type = object({
    enabled       = optional(bool, false)
    s3_bucket     = optional(string)
    s3_key_prefix = optional(string)
    s3_key_format = optional(string, "SIMPLE")

    is_target_bucket       = optional(bool, false)
    allowed_source_buckets = optional(list(string), [])
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["SIMPLE", "PARTITIONED_BY_DELIVERY_TIME", "PARTITIONED_BY_EVENT_TIME"], var.logging.s3_key_format)
    error_message = "Valid values for `logging.s3_key_format` are `SIMPLE`, `PARTITIONED_BY_DELIVERY_TIME` and `PARTITIONED_BY_EVENT_TIME`."
  }
}

variable "request_metrics" {
  description = <<EOF
  (Optional) A list of CORS (Cross-Origin Resource Sharing) rules for the bucket. You can configure up to 100 rules. Each value of `cors_rules` as defined below.
    (Required) `name` - Unique identifier of the metrics configuration for the bucket. Must be less than or equal to 64 characters in length.
    (Optional) `filter` - Object filtering that accepts a prefix, tags, or a logical AND of prefix and tags. `filter` block as defined below.
      (Optional) `access_point` - The access point ARN used when evaluating a metrics filter.
      (Optional) `prefix` - The prefix used when evaluating a metrics filter.
      (Optional) `tags` - The tag used when evaluating a metrics filter. Up to 10 key/value pairs.
  EOF
  type = list(object({
    name = string
    filter = optional(object({
      access_point = optional(string)
      prefix       = optional(string)
      tags         = optional(map(string), {})
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

variable "timeouts" {
  description = "(Optional) How long to wait for the S3 bucket to be created/read/updated/deleted."
  type = object({
    create = optional(string, "20m")
    read   = optional(string, "20m")
    update = optional(string, "20m")
    delete = optional(string, "65m")
  })
  default  = {}
  nullable = false
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

variable "resource_group" {
  description = <<EOF
  (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.
    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.
    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.
    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`.
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string, "")
    description = optional(string, "Managed by Terraform.")
  })
  default  = {}
  nullable = false
}
