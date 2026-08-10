variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "table_bucket" {
  description = "(Required) The ARN of the S3 table bucket to create the table in."
  type        = string
  nullable    = false
}

variable "namespace" {
  description = "(Required) The name of the namespace for the table. The namespace must exist in the table bucket."
  type        = string
  nullable    = false
}

variable "name" {
  description = "(Required) Desired name for the S3 table. Must be between 1 and 255 characters in length. Can consist of lowercase letters, numbers, and underscores, and must begin and end with a lowercase letter or number."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9]$|^[a-z0-9][a-z0-9_]{0,253}[a-z0-9]$", var.name))
    error_message = "The name must be between 1 and 255 characters in length, can consist of lowercase letters, numbers, and underscores, and must begin and end with a lowercase letter or number."
  }
}

variable "format" {
  description = "(Optional) The format of the table. Only `ICEBERG` is supported. Defaults to `ICEBERG`."
  type        = string
  default     = "ICEBERG"
  nullable    = false

  validation {
    condition     = contains(["ICEBERG"], var.format)
    error_message = "Valid values for `format` are `ICEBERG`."
  }
}

variable "encryption" {
  description = <<EOF
  (Optional) A configurations of Server-Side Encryption for the S3 table. If not provided, the table inherits the encryption configuration of the table bucket. `encryption` as defined below.
    (Optional) `type` - The server-side encryption algorithm to use. Valid values are `AES256` and `AWS_KMS`. Defaults to `AES256`.
    (Optional) `kms_key` - The ARN of the AWS KMS key used for the `SSE-KMS` encryption. This can only be used when you set the value of `encryption.type` as `AWS_KMS`.
  EOF
  type = object({
    type    = optional(string, "AES256")
    kms_key = optional(string)
  })
  default  = null
  nullable = true

  validation {
    condition     = var.encryption == null ? true : contains(["AES256", "AWS_KMS"], var.encryption.type)
    error_message = "Valid values for `encryption.type` are `AES256`, `AWS_KMS`."
  }
}

variable "metadata" {
  description = <<EOF
  (Optional) A configuration of the metadata for the Iceberg table. Only used to define the initial metadata when the table is created. The schema is evolved by query engines afterwards. `metadata` as defined below.
    (Optional) `schema` - A list of schema fields for the Iceberg table. Each field defines a column in the table schema, and the order of the fields defines the column order. Each value of `schema` as defined below.
      (Required) `name` - The name of the field.
      (Required) `type` - The field type. S3 Tables supports all Apache Iceberg primitive types including `boolean`, `int`, `long`, `float`, `double`, `decimal(precision,scale)`, `date`, `time`, `timestamp`, `timestamptz`, `string`, `uuid`, `fixed(length)`, `binary`.
      (Optional) `required` - Whether values are required for each row in this field. Defaults to `false`.
    (Optional) `properties` - A map of configuration properties for the Iceberg table, for example `write.distribution-mode` and `write.sort-order`. Can only be used with `schema`. Changing this forces a new table to be created.
  EOF
  type = object({
    schema = optional(list(object({
      name     = string
      type     = string
      required = optional(bool, false)
    })), [])
    properties = optional(map(string), {})
  })
  default  = {}
  nullable = false

  validation {
    condition     = length(distinct(var.metadata.schema[*].name)) == length(var.metadata.schema)
    error_message = "`name` of each field must be unique within `metadata.schema`."
  }
  validation {
    # INFO: The provider requires `metadata[0].iceberg[0].schema` when the `metadata` block is present.
    condition     = length(var.metadata.properties) == 0 || length(var.metadata.schema) > 0
    error_message = "`metadata.properties` can only be used when `metadata.schema` is provided."
  }
}

variable "maintenance" {
  description = <<EOF
  (Optional) A configurations of maintenance for the S3 table. `compaction` and `snapshot_management` can be configured independently, and each is enabled by default. `maintenance` as defined below.
    (Optional) `compaction` - A configuration for the Iceberg compaction maintenance, which combines small data objects to improve query performance. `compaction` as defined below.
      (Optional) `enabled` - Whether the compaction maintenance is enabled. Defaults to `true`.
      (Optional) `target_file_size_mb` - The target file size in MB. Data objects smaller than this size may be combined with others to improve query performance. Must be between `64` and `512`. Defaults to `512`.
    (Optional) `snapshot_management` - A configuration for the Iceberg snapshot management maintenance, which deletes old table snapshots. `snapshot_management` as defined below.
      (Optional) `enabled` - Whether the snapshot management maintenance is enabled. Defaults to `true`.
      (Optional) `max_snapshot_age_hours` - Snapshots older than this many hours will be marked for deletion. Must be at least `1`. Defaults to `120`.
      (Optional) `min_snapshots_to_keep` - The minimum number of snapshots to keep. Must be at least `1`. Defaults to `1`.
  EOF
  type = object({
    compaction = optional(object({
      enabled             = optional(bool, true)
      target_file_size_mb = optional(number, 512)
    }), {})
    snapshot_management = optional(object({
      enabled                = optional(bool, true)
      max_snapshot_age_hours = optional(number, 120)
      min_snapshots_to_keep  = optional(number, 1)
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      var.maintenance.compaction.target_file_size_mb >= 64,
      var.maintenance.compaction.target_file_size_mb <= 512,
    ])
    error_message = "`maintenance.compaction.target_file_size_mb` must be between `64` and `512`."
  }
  validation {
    condition = alltrue([
      var.maintenance.snapshot_management.max_snapshot_age_hours >= 1,
      var.maintenance.snapshot_management.min_snapshots_to_keep >= 1,
    ])
    error_message = "`max_snapshot_age_hours` and `min_snapshots_to_keep` must be at least `1`."
  }
}

variable "policy" {
  description = "(Optional) A valid resource policy JSON document for the S3 table. Although this is a table policy, not an IAM policy, the `aws_iam_policy_document` data source may be used, so long as it specifies a principal."
  type        = string
  default     = null
  nullable    = true
}

variable "replication" {
  description = <<EOF
  (Optional) A configurations of Replication for the S3 table. The table-level replication configuration overrides the bucket-level replication configuration for this table. `replication` as defined below.
    (Optional) `rules` - A list of replication rules. The service currently supports only one rule per replication configuration. Each value of `rules` as defined below.
      (Required) `destinations` - A set of ARNs of the destination table buckets to replicate the source table to. Each rule supports up to 5 destinations.
    (Optional) `service_role` - The ARN (Amazon Resource Name) of the IAM Role that Amazon S3 assumes when replicating the table. Only required if `replication.default_service_role.enabled` is `false`.
    (Optional) `default_service_role` - A configuration for the default service role for the table replication. Use `replication.service_role` if `replication.default_service_role.enabled` is `false`. Add KMS permissions with `policies` or `inline_policies` if the table is encrypted with KMS. `default_service_role` as defined below.
      (Optional) `enabled` - Whether to create the default service role. Defaults to `true`.
      (Optional) `name` - The name of the default service role. Defaults to `s3tables-$${bucket-name}-$${var.name}-replication`.
      (Optional) `path` - The path of the default service role. Defaults to `/`.
      (Optional) `description` - The description of the default service role.
      (Optional) `policies` - A list of IAM policy ARNs to attach to the default service role. Defaults to `[]`.
      (Optional) `inline_policies` - A Map of inline IAM policies to attach to the default service role. (`name` => `policy`).
      (Optional) `permissions_boundary` - The ARN of the IAM policy to use as permissions boundary for the default service role.
  EOF
  type = object({
    rules = optional(list(object({
      destinations = set(string)
    })), [])

    service_role = optional(string)
    default_service_role = optional(object({
      enabled     = optional(bool, true)
      name        = optional(string)
      path        = optional(string, "/")
      description = optional(string, "Managed by Terraform.")

      policies             = optional(list(string), [])
      inline_policies      = optional(map(string), {})
      permissions_boundary = optional(string)
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for rule in var.replication.rules :
      length(rule.destinations) >= 1 && length(rule.destinations) <= 5
    ])
    error_message = "Each rule must have between `1` and `5` destinations."
  }
  validation {
    condition = (length(var.replication.rules) == 0
      || var.replication.default_service_role.enabled
      || var.replication.service_role != null
    )
    error_message = "`replication.service_role` is required if `replication.default_service_role.enabled` is `false`."
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
