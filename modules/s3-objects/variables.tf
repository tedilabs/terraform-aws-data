variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) Desired name for the module instance. Used for the module metadata and the Resource Group name."
  type        = string
  nullable    = false
}

variable "bucket" {
  description = "(Required) The name of the S3 bucket to put the objects in."
  type        = string
  nullable    = false
}

variable "force_destroy" {
  description = "(Optional) Whether to allow the objects to be deleted while the bucket has a legal hold on the objects. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "checksum" {
  description = <<EOF
  (Optional) A configurations of the additional checksum for the objects. The checksum is calculated on upload, stored with the objects, and used by S3 to verify the integrity of the object data. `checksum` as defined below.
    (Optional) `enabled` - Whether to calculate an additional checksum for the objects. Defaults to `true`.
    (Optional) `algorithm` - The algorithm used to create the checksum for the objects. Valid values are `CRC32`, `CRC32C`, `CRC64NVME`, `SHA1` and `SHA256`. Defaults to `CRC32`. If the objects are encrypted with SSE-KMS (`aws:kms`), the IAM identity running Terraform must be allowed to perform the `kms:Decrypt` action on the KMS key, because S3 requires it to read the checksum back from a SSE-KMS encrypted object.
  EOF
  type = object({
    enabled   = optional(bool, true)
    algorithm = optional(string, "CRC32")
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["CRC32", "CRC32C", "CRC64NVME", "SHA1", "SHA256"], var.checksum.algorithm)
    error_message = "Valid values for `checksum.algorithm` are `CRC32`, `CRC32C`, `CRC64NVME`, `SHA1`, `SHA256`."
  }
}

variable "encryption" {
  description = <<EOF
  (Optional) A configurations of Server-Side Encryption for the objects. Each attribute only overrides the default encryption configuration of the bucket when explicitly provided. If not provided, the objects follow the default encryption configuration of the bucket. `encryption` as defined below.
    (Optional) `type` - The server-side encryption algorithm to use for the objects. Valid values are `AES256`, `AWS_KMS` and `AWS_KMS_DSSE`. If not provided, the default encryption type of the bucket is applied.
    (Optional) `kms_key` - The ARN of the AWS KMS key used for the `SSE-KMS` encryption. This can only be used when the value of `encryption.type` is `AWS_KMS` or `AWS_KMS_DSSE`. The default encryption KMS key of the bucket or the AWS managed `aws/s3` KMS key is used if this element is absent.
    (Optional) `bucket_key_enabled` - Whether or not to use Amazon S3 Bucket Keys for SSE-KMS. If not provided, the default Bucket Keys configuration of the bucket is applied.
  EOF
  type = object({
    type               = optional(string)
    kms_key            = optional(string)
    bucket_key_enabled = optional(bool)
  })
  default  = {}
  nullable = false

  validation {
    condition = (var.encryption.type == null
      ? true
      : contains(["AES256", "AWS_KMS", "AWS_KMS_DSSE"], var.encryption.type)
    )
    error_message = "Valid values for `encryption.type` are `AES256`, `AWS_KMS`, `AWS_KMS_DSSE`."
  }
}

variable "object_lock" {
  description = <<EOF
  (Optional) A configurations of Object Lock for the objects. Object Lock must be enabled on the bucket with versioning to use these settings. To delete the objects locked by a legal hold or a retention via Terraform, `force_destroy` must be enabled. `object_lock` as defined below.
    (Optional) `legal_hold_enabled` - Whether to apply a legal hold to the objects. A legal hold protects the objects indefinitely until it is explicitly removed. If not provided, the legal hold status of the objects is not managed. Set to `false` to explicitly remove a legal hold from the existing objects.
    (Optional) `retention` - A configuration of the Object Lock retention for the objects. If not provided, the default Object Lock retention of the bucket is applied. `retention` as defined below.
      (Optional) `mode` - The Object Lock retention mode for the objects. Valid values are `GOVERNANCE` and `COMPLIANCE`. `GOVERNANCE` can be bypassed with the `s3:BypassGovernanceRetention` permission, while `COMPLIANCE` cannot be shortened by anyone including the root user until the retention expires. Defaults to `GOVERNANCE`.
      (Required) `retain_until_date` - The date and time when the objects can be deleted or modified again, in RFC3339 format (e.g. `2030-01-01T00:00:00Z`).
  EOF
  type = object({
    legal_hold_enabled = optional(bool)
    retention = optional(object({
      mode              = optional(string, "GOVERNANCE")
      retain_until_date = string
    }))
  })
  default  = {}
  nullable = false

  validation {
    condition = (var.object_lock.retention == null
      ? true
      : contains(["GOVERNANCE", "COMPLIANCE"], var.object_lock.retention.mode)
    )
    error_message = "Valid values for `object_lock.retention.mode` are `GOVERNANCE`, `COMPLIANCE`."
  }
  validation {
    condition = (var.object_lock.retention == null
      ? true
      : can(formatdate("YYYY", var.object_lock.retention.retain_until_date))
    )
    error_message = "`object_lock.retention.retain_until_date` must be a valid RFC3339 timestamp."
  }
}

variable "metadata" {
  description = "(Optional) A map of keys/values to provision metadata for all objects. Merged with the `metadata` of each value of `files` and `directories`, and the object level metadata takes precedence over the common metadata on key conflicts. Metadata keys are always converted to lowercase by AWS. Note that changing the metadata triggers re-upload of all objects."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "files" {
  description = <<EOF
  (Optional) A list of files to upload to the S3 bucket. Each file is uploaded as an object from a local file or an inline content. Each object key takes precedence over objects from `directories` when the object keys conflict. Each value of `files` as defined below.
    (Required) `key` - The full key (path) of the object in the S3 bucket. The key must be unique within `files`.
    (Optional) `source` - The path to a local file that will be uploaded as the object content. Exactly one of `source` or `content` must be provided. The object is automatically re-uploaded when the content of the file changes.
    (Optional) `content` - The literal string value to use as the object content. Exactly one of `source` or `content` must be provided.
    (Optional) `content_type` - The standard MIME type of the object content. If not provided, the content type is inferred from the file extension of `key`. Defaults to `application/octet-stream` if the extension is unknown.
    (Optional) `storage_class` - The storage class of the object. Valid values are `STANDARD`, `REDUCED_REDUNDANCY`, `STANDARD_IA`, `ONEZONE_IA`, `INTELLIGENT_TIERING`, `GLACIER`, `DEEP_ARCHIVE`, `GLACIER_IR` and `EXPRESS_ONEZONE`. If not provided, the object is created as `STANDARD`, and the storage class transitioned afterward by the bucket lifecycle rules is kept as is. Explicitly providing a value reverts the transitioned storage class back on the next apply by re-uploading the object.
    (Optional) `cache_control` - The caching behavior along the request/reply chain. Read [w3c cache_control](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.9) for further details.
    (Optional) `content_disposition` - The presentational information for the object. Read [w3c content_disposition](http://www.w3.org/Protocols/rfc2616/rfc2616-sec19.html#sec19.5.1) for further details.
    (Optional) `content_encoding` - The content encodings that have been applied to the object and thus what decoding mechanisms must be applied to obtain the media-type referenced by the `content_type`.
    (Optional) `content_language` - The language the object content is in.
    (Optional) `website_redirect` - The target URL for website redirect.
    (Optional) `metadata` - A map of keys/values to provision metadata. Metadata keys are always converted to lowercase by AWS.
    (Optional) `tags` - A map of tags to add to the object.
  EOF
  type = list(object({
    key = string

    source       = optional(string)
    content      = optional(string)
    content_type = optional(string)

    storage_class       = optional(string)
    cache_control       = optional(string)
    content_disposition = optional(string)
    content_encoding    = optional(string)
    content_language    = optional(string)
    website_redirect    = optional(string)
    metadata            = optional(map(string), {})

    tags = optional(map(string), {})
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for file in var.files :
      length(file.key) > 0
    ])
    error_message = "`key` of each file cannot be empty."
  }
  validation {
    condition     = length(distinct(var.files[*].key)) == length(var.files)
    error_message = "`key` of each file must be unique within `files`."
  }
  validation {
    condition = alltrue([
      for file in var.files :
      (file.source != null) != (file.content != null)
    ])
    error_message = "Exactly one of `source` or `content` must be provided for each file."
  }
  validation {
    condition = alltrue([
      for file in var.files :
      (file.storage_class == null
        ? true
        : contains(["STANDARD", "REDUCED_REDUNDANCY", "STANDARD_IA", "ONEZONE_IA", "INTELLIGENT_TIERING", "GLACIER", "DEEP_ARCHIVE", "GLACIER_IR", "EXPRESS_ONEZONE"], file.storage_class)
      )
    ])
    error_message = "Valid values for `storage_class` are `STANDARD`, `REDUCED_REDUNDANCY`, `STANDARD_IA`, `ONEZONE_IA`, `INTELLIGENT_TIERING`, `GLACIER`, `DEEP_ARCHIVE`, `GLACIER_IR`, `EXPRESS_ONEZONE`."
  }
}

variable "directories" {
  description = <<EOF
  (Optional) A list of local directories to sync to the S3 bucket. All files matched in each directory are uploaded as individual objects. Objects defined in `files` take precedence over objects from `directories` when the object keys conflict. A key collision between two directories results in a plan-time error. Each value of `directories` as defined below.
    (Required) `path` - The path to a local directory to sync to the S3 bucket.
    (Optional) `key_prefix` - The key prefix to prepend to each object key. The object key is built as `key_prefix` followed by the file path relative to `path`. Defaults to an empty string (`""`).
    (Optional) `include_patterns` - A list of glob patterns to include files in the directory. Defaults to `["**"]` (all files).
    (Optional) `exclude_patterns` - A list of glob patterns to exclude files from the matched files. Defaults to `[]`.
    (Optional) `content_type` - The standard MIME type of the objects. If not provided, the content type is inferred from the file extension of each object key. Defaults to `application/octet-stream` if the extension is unknown.
    (Optional) `storage_class` - The storage class of the objects. Valid values are `STANDARD`, `REDUCED_REDUNDANCY`, `STANDARD_IA`, `ONEZONE_IA`, `INTELLIGENT_TIERING`, `GLACIER`, `DEEP_ARCHIVE`, `GLACIER_IR` and `EXPRESS_ONEZONE`. If not provided, the objects are created as `STANDARD`, and the storage class transitioned afterward by the bucket lifecycle rules is kept as is. Explicitly providing a value reverts the transitioned storage class back on the next apply by re-uploading the objects.
    (Optional) `cache_control` - The caching behavior along the request/reply chain for the objects.
    (Optional) `content_disposition` - The presentational information for the objects.
    (Optional) `content_encoding` - The content encodings that have been applied to the objects and thus what decoding mechanisms must be applied to obtain the media-type referenced by the `content_type`.
    (Optional) `content_language` - The language the object contents are in.
    (Optional) `metadata` - A map of keys/values to provision metadata for the objects. Metadata keys are always converted to lowercase by AWS.
    (Optional) `tags` - A map of tags to add to the objects.
  EOF
  type = list(object({
    path             = string
    key_prefix       = optional(string, "")
    include_patterns = optional(list(string), ["**"])
    exclude_patterns = optional(list(string), [])

    content_type = optional(string)

    storage_class       = optional(string)
    cache_control       = optional(string)
    content_disposition = optional(string)
    content_encoding    = optional(string)
    content_language    = optional(string)
    metadata            = optional(map(string), {})

    tags = optional(map(string), {})
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for directory in var.directories :
      (directory.storage_class == null
        ? true
        : contains(["STANDARD", "REDUCED_REDUNDANCY", "STANDARD_IA", "ONEZONE_IA", "INTELLIGENT_TIERING", "GLACIER", "DEEP_ARCHIVE", "GLACIER_IR", "EXPRESS_ONEZONE"], directory.storage_class)
      )
    ])
    error_message = "Valid values for `storage_class` are `STANDARD`, `REDUCED_REDUNDANCY`, `STANDARD_IA`, `ONEZONE_IA`, `INTELLIGENT_TIERING`, `GLACIER`, `DEEP_ARCHIVE`, `GLACIER_IR`, `EXPRESS_ONEZONE`."
  }
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

variable "provider_default_tags_enabled" {
  description = "(Optional) Whether to apply the provider-level `default_tags` to the objects. S3 objects support a maximum of 10 tags, and exceeding the limit results in an API error on upload. The provider-level `default_tags` are ignored by default to save the tag quota for the module tags and the user-defined tags. Defaults to `false`."
  type        = bool
  default     = false
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
