variable "name" {
  description = "(Required) The name that you want to use to describe the new QuickSight namespace."
  type        = string
  nullable    = false
}

variable "identity_store" {
  description = "(Optional) The type of user identity directory. Defaults to `QUICKSIGHT`, the only current valid value."
  type        = string
  default     = "QUICKSIGHT"
  nullable    = false

  validation {
    condition     = contains(["QUICKSIGHT"], var.identity_store)
    error_message = "Valid values for `identity_store` are `QUICKSIGHT`."
  }
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
