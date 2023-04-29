variable "name" {
  description = "(Required) An identifier for the QuickSight folder."
  type        = string
  nullable    = false
}

variable "display_name" {
  description = "(Optional) A display name for the QuickSight folder."
  type        = string
  default     = null
  nullable    = true
}

variable "type" {
  description = "(Optional) The type of the QuickSight folder. Valid values are `SHARED`. Defaults to `SHARED`."
  type        = string
  default     = "SHARED"
  nullable    = false
  validation {
    condition     = contains(["SHARED"], var.type)
    error_message = "Valid values for `type` are `SHARED`."
  }
}

variable "parent_folder" {
  description = "(Optional) The Amazon Resource Name (ARN) for the parent folder. If not set, creates a root-level folder."
  type        = string
  default     = null
  nullable    = true
}

variable "permissions" {
  description = <<EOF
  (Optional) A list of resource permissions on the QuickSight folder. Maximum of 64 items. Each value of `permissions` as defined below.
    (Required) `principal` - The Amazon Resource Name (ARN) of the principal. This can be one of the following:
      - The ARN of an Amazon QuickSight user or group associated with a data source or dataset. (This is common.)
      - The ARN of an Amazon QuickSight user, group, or namespace associated with an analysis, dashboard, template, or theme. (This is common.)
      - The ARN of an Amazon Web Services account root: This is an IAM ARN rather than a QuickSight ARN. Use this option only to share resources (templates) across Amazon Web Services accounts. (This is less common.)
    (Optional) `role` - A role of principal with a pre-defined set of permissions. Valid values are `OWNER` and `READER`.
    (Optional) `actions` - A set of IAM actions to grant or revoke permissions on.
  EOF
  type = list(object({
    principal = string
    role      = optional(string)
    actions   = optional(set(string), [])
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for permission in var.permissions :
      contains(["OWNER", "READER"], permission.role)
    ])
    error_message = "Valid values for `permission.role` are `OWNER` and `READER`."
  }
}

variable "assets" {
  description = <<EOF
  (Optional) A configuration for assets of this QuickSight folder. `assets` as defined below.
    (Optional) `analyses` - A list of the IDs of the analysis assets to add to this QuickSight folder.
    (Optional) `dashboards` - A list of the IDs of the dashboard assets to add to this QuickSight folder.
    (Optional) `datasets` - A list of the IDs of the dataset assets to add to this QuickSight folder.
  EOF
  type = object({
    analyses   = optional(list(string), [])
    dashboards = optional(list(string), [])
    datasets   = optional(list(string), [])
  })
  default  = {}
  nullable = false
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module informations."
  type        = bool
  default     = true
}


###################################################
# Resource Group
###################################################

variable "resource_group_enabled" {
  description = "(Optional) Whether to create Resource Group to find and group AWS resources which are created by this module."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "(Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`."
  type        = string
  default     = ""
}

variable "resource_group_description" {
  description = "(Optional) The description of Resource Group."
  type        = string
  default     = "Managed by Terraform."
}
