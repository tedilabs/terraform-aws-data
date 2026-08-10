variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) Desired name for the S3 table bucket. Must be between 3 and 63 characters in length. Can consist of lowercase letters, numbers, and hyphens, and must begin and end with a lowercase letter or number."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.name))
    error_message = "The name must be between 3 and 63 characters in length, can consist of lowercase letters, numbers, and hyphens, and must begin and end with a lowercase letter or number."
  }
}

variable "force_destroy" {
  description = "(Optional) A bool that indicates all tables and namespaces within the table bucket should be deleted when the table bucket is destroyed so that the table bucket can be destroyed without error. These tables and namespaces are not recoverable. A successful `terraform apply` run is required after this parameter is set to `true` before it takes effect on a destroy operation. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "encryption" {
  description = <<EOF
  (Optional) A configurations of Server-Side Encryption for the S3 table bucket. `encryption` as defined below.
    (Optional) `type` - The server-side encryption algorithm to use. Valid values are `AES256` and `AWS_KMS`. Defaults to `AES256`.
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

variable "maintenance" {
  description = <<EOF
  (Optional) A configurations of maintenance for the S3 table bucket. If not provided, the maintenance configuration is fully managed by AWS with the service default values. `maintenance` as defined below.
    (Optional) `unreferenced_file_removal` - A configuration for the unreferenced file removal maintenance, which deletes objects that are not referenced by any table snapshot. `unreferenced_file_removal` as defined below.
      (Optional) `enabled` - Whether the unreferenced file removal maintenance is enabled. Defaults to `true`.
      (Required) `unreferenced_days` - The number of days an object must be unreferenced by the table before it is marked for deletion. Must be at least `1`.
      (Required) `non_current_days` - The number of days an object marked for deletion can be noncurrent before it is deleted. Must be at least `1`.
  EOF
  type = object({
    unreferenced_file_removal = optional(object({
      enabled           = optional(bool, true)
      unreferenced_days = number
      non_current_days  = number
    }))
  })
  default  = {}
  nullable = false

  validation {
    condition = (var.maintenance.unreferenced_file_removal == null
      ? true
      : alltrue([
        var.maintenance.unreferenced_file_removal.unreferenced_days >= 1,
        var.maintenance.unreferenced_file_removal.non_current_days >= 1,
      ])
    )
    error_message = "`unreferenced_days` and `non_current_days` must be at least `1`."
  }
}

variable "namespaces" {
  description = "(Optional) A set of names of namespaces to create in the S3 table bucket. Namespaces are used to logically group tables in the table bucket. Each name must be between 1 and 255 characters in length, can consist of lowercase letters, numbers, and underscores, and must begin and end with a lowercase letter or number."
  type        = set(string)
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for namespace in var.namespaces :
      can(regex("^[a-z0-9]$|^[a-z0-9][a-z0-9_]{0,253}[a-z0-9]$", namespace))
    ])
    error_message = "Each namespace must be between 1 and 255 characters in length, can consist of lowercase letters, numbers, and underscores, and must begin and end with a lowercase letter or number."
  }
}

variable "policy" {
  description = "(Optional) A valid resource policy JSON document for the S3 table bucket. Although this is a table bucket policy, not an IAM policy, the `aws_iam_policy_document` data source may be used, so long as it specifies a principal."
  type        = string
  default     = null
  nullable    = true
}

variable "replication" {
  description = <<EOF
  (Optional) A configurations of Replication for the S3 table bucket. Replication applies to all tables in the source table bucket. `replication` as defined below.
    (Optional) `rules` - A list of replication rules. The service currently supports only one rule per replication configuration. Each value of `rules` as defined below.
      (Required) `destinations` - A set of ARNs of the destination table buckets to replicate source tables to. Each rule supports up to 5 destinations.
    (Optional) `service_role` - The ARN (Amazon Resource Name) of the IAM Role that Amazon S3 assumes when replicating tables. Only required if `replication.default_service_role.enabled` is `false`.
    (Optional) `default_service_role` - A configuration for the default service role for the table bucket replication. Use `replication.service_role` if `replication.default_service_role.enabled` is `false`. Add KMS permissions with `policies` or `inline_policies` if the tables are encrypted with KMS. `default_service_role` as defined below.
      (Optional) `enabled` - Whether to create the default service role. Defaults to `true`.
      (Optional) `name` - The name of the default service role. Defaults to `s3tables-$${var.name}-replication`.
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
