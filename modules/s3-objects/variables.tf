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

variable "files" {
  description = <<EOF
  (Optional) A list of files to upload to the S3 bucket. Each file is uploaded as an object from a local file or an inline content. Each object key takes precedence over objects from `directories` when the object keys conflict. Each value of `files` as defined below.
    (Required) `key` - The full key (path) of the object in the S3 bucket. The key must be unique within `files`.
    (Optional) `source` - The path to a local file that will be uploaded as the object content. Exactly one of `source` or `content` must be provided. The object is automatically re-uploaded when the content of the file changes.
    (Optional) `content` - The literal string value to use as the object content. Exactly one of `source` or `content` must be provided.
    (Optional) `content_type` - The standard MIME type of the object content. If not provided, the content type is inferred from the file extension of `key`. Defaults to `application/octet-stream` if the extension is unknown.
    (Optional) `storage_class` - The storage class of the object. Valid values are `STANDARD`, `REDUCED_REDUNDANCY`, `STANDARD_IA`, `ONEZONE_IA`, `INTELLIGENT_TIERING`, `GLACIER`, `DEEP_ARCHIVE`, `GLACIER_IR` and `EXPRESS_ONEZONE`. Defaults to `STANDARD`.
    (Optional) `cache_control` - The caching behavior along the request/reply chain. Read [w3c cache_control](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.9) for further details.
    (Optional) `content_disposition` - The presentational information for the object. Read [w3c content_disposition](http://www.w3.org/Protocols/rfc2616/rfc2616-sec19.html#sec19.5.1) for further details.
    (Optional) `content_encoding` - The content encodings that have been applied to the object and thus what decoding mechanisms must be applied to obtain the media-type referenced by the `content_type`.
    (Optional) `content_language` - The language the object content is in.
    (Optional) `website_redirect` - The target URL for website redirect.
    (Optional) `metadata` - A map of keys/values to provision metadata. Metadata keys are always converted to lowercase by AWS.
    (Optional) `force_destroy` - Whether to allow the object to be deleted while the bucket has a legal hold on the object. Defaults to `false`.
    (Optional) `tags` - A map of tags to add to the object.
  EOF
  type = list(object({
    key = string

    source       = optional(string)
    content      = optional(string)
    content_type = optional(string)

    storage_class       = optional(string, "STANDARD")
    cache_control       = optional(string)
    content_disposition = optional(string)
    content_encoding    = optional(string)
    content_language    = optional(string)
    website_redirect    = optional(string)
    metadata            = optional(map(string), {})

    force_destroy = optional(bool, false)
    tags          = optional(map(string), {})
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
      contains(["STANDARD", "REDUCED_REDUNDANCY", "STANDARD_IA", "ONEZONE_IA", "INTELLIGENT_TIERING", "GLACIER", "DEEP_ARCHIVE", "GLACIER_IR", "EXPRESS_ONEZONE"], file.storage_class)
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
    (Optional) `storage_class` - The storage class of the objects. Valid values are `STANDARD`, `REDUCED_REDUNDANCY`, `STANDARD_IA`, `ONEZONE_IA`, `INTELLIGENT_TIERING`, `GLACIER`, `DEEP_ARCHIVE`, `GLACIER_IR` and `EXPRESS_ONEZONE`. Defaults to `STANDARD`.
    (Optional) `cache_control` - The caching behavior along the request/reply chain for the objects.
    (Optional) `metadata` - A map of keys/values to provision metadata for the objects. Metadata keys are always converted to lowercase by AWS.
    (Optional) `force_destroy` - Whether to allow the objects to be deleted while the bucket has a legal hold on the objects. Defaults to `false`.
    (Optional) `tags` - A map of tags to add to the objects.
  EOF
  type = list(object({
    path             = string
    key_prefix       = optional(string, "")
    include_patterns = optional(list(string), ["**"])
    exclude_patterns = optional(list(string), [])

    storage_class = optional(string, "STANDARD")
    cache_control = optional(string)
    metadata      = optional(map(string), {})

    force_destroy = optional(bool, false)
    tags          = optional(map(string), {})
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for directory in var.directories :
      contains(["STANDARD", "REDUCED_REDUNDANCY", "STANDARD_IA", "ONEZONE_IA", "INTELLIGENT_TIERING", "GLACIER", "DEEP_ARCHIVE", "GLACIER_IR", "EXPRESS_ONEZONE"], directory.storage_class)
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
