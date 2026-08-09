variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) Desired name for the S3 vector bucket. Must be between 3 and 63 characters in length. Can consist of lowercase letters, numbers, and hyphens, and must begin and end with a lowercase letter or number."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.name))
    error_message = "The name must be between 3 and 63 characters in length, can consist of lowercase letters, numbers, and hyphens, and must begin and end with a lowercase letter or number."
  }
}

variable "force_destroy" {
  description = "(Optional) A bool that indicates all indexes and vectors should be deleted from the vector bucket when the vector bucket is destroyed so that the vector bucket can be destroyed without error. A successful `terraform apply` run is required after this parameter is set to `true` before it takes effect on a destroy operation. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "encryption" {
  description = <<EOF
  (Optional) A configurations of Server-Side Encryption for the S3 vector bucket. Changing this forces a new vector bucket to be created. `encryption` as defined below.
    (Optional) `type` - The server-side encryption type to use. Valid values are `AES256` and `AWS_KMS`. Defaults to `AES256`.
    (Optional) `kms_key` - The ARN of the AWS KMS key used for the `SSE-KMS` encryption. This can only be used when you set the value of `encryption.type` as `AWS_KMS`.
  EOF
  type = object({
    type    = optional(string, "AES256")
    kms_key = optional(string)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["AES256", "AWS_KMS"], var.encryption.type)
    error_message = "Valid values for `encryption.type` are `AES256`, `AWS_KMS`."
  }
}

variable "indexes" {
  description = <<EOF
  (Optional) A list of vector indexes to create in the S3 vector bucket. A vector index is used to organize and logically group vector data. All arguments of a vector index force a new resource to be created when changed, and the vectors stored in the index are not recoverable. Each value of `indexes` as defined below.
    (Required) `name` - The name of the vector index. The name must be unique within `indexes`.
    (Required) `dimension` - The dimensions of the vectors to be inserted into the vector index. Must be between `1` and `4096`.
    (Optional) `distance_metric` - The distance metric to be used for similarity search. Valid values are `cosine` and `euclidean`. Defaults to `cosine`.
    (Optional) `data_type` - The data type of the vectors to be inserted into the vector index. Only `float32` is supported. Defaults to `float32`.
    (Optional) `encryption` - A configuration of Server-Side Encryption for the vector index. If not provided, the encryption configuration of the vector bucket is used. `encryption` as defined below.
      (Optional) `type` - The server-side encryption type to use. Valid values are `AES256` and `AWS_KMS`. Defaults to `AES256`.
      (Optional) `kms_key` - The ARN of the AWS KMS key used for the `SSE-KMS` encryption. This can only be used when you set the value of `encryption.type` as `AWS_KMS`.
    (Optional) `metadata` - A configuration of the metadata for the vector index. `metadata` as defined below.
      (Optional) `non_filterable_keys` - A set of metadata keys that cannot be used as query filters. Non-filterable metadata is only returned with query results.
    (Optional) `tags` - A map of tags to add to the vector index.
  EOF
  type = list(object({
    name = string

    dimension       = number
    distance_metric = optional(string, "cosine")
    data_type       = optional(string, "float32")

    encryption = optional(object({
      type    = optional(string, "AES256")
      kms_key = optional(string)
    }))
    metadata = optional(object({
      non_filterable_keys = optional(set(string), [])
    }), {})

    tags = optional(map(string), {})
  }))
  default  = []
  nullable = false

  validation {
    condition     = length(distinct(var.indexes[*].name)) == length(var.indexes)
    error_message = "`name` of each vector index must be unique within `indexes`."
  }
  validation {
    condition = alltrue([
      for index in var.indexes :
      index.dimension >= 1 && index.dimension <= 4096
    ])
    error_message = "`dimension` of each vector index must be between `1` and `4096`."
  }
  validation {
    condition = alltrue([
      for index in var.indexes :
      contains(["cosine", "euclidean"], index.distance_metric)
    ])
    error_message = "Valid values for `distance_metric` are `cosine`, `euclidean`."
  }
  validation {
    condition = alltrue([
      for index in var.indexes :
      contains(["float32"], index.data_type)
    ])
    error_message = "Valid values for `data_type` are `float32`."
  }
  validation {
    condition = alltrue([
      for index in var.indexes :
      index.encryption == null ? true : contains(["AES256", "AWS_KMS"], index.encryption.type)
    ])
    error_message = "Valid values for `encryption.type` of each vector index are `AES256`, `AWS_KMS`."
  }
}

variable "policy" {
  description = "(Optional) A valid resource policy JSON document for the S3 vector bucket. Although this is a vector bucket policy, not an IAM policy, the `aws_iam_policy_document` data source may be used, so long as it specifies a principal."
  type        = string
  default     = null
  nullable    = true
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
