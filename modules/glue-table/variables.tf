variable "catalog" {
  description = "(Optional) The ID of the Data Catalog in which to create the table. If omitted, this defaults to the AWS Account ID."
  type        = string
  default     = null
}

variable "database" {
  description = "(Required) The name of the metadata database where the table metadata resides. For Hive compatibility, this name must be all lowercase."
  type        = string
  nullable    = false
}

variable "name" {
  description = "(Required) The name of the table. For Hive compatibility, this must be entirely lowercase."
  type        = string
  nullable    = false
}

variable "description" {
  description = "(Optional) The description of the table."
  type        = string
  default     = "Managed by Terraform."
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





###################################################
# Resource Sharing by RAM (Resource Access Manager)
###################################################

variable "shares" {
  description = "(Optional) A list of resource shares via RAM (Resource Access Manager)."
  type = list(object({
    name = optional(string)

    # INFO
    # - `AWSRAMDefaultPermissionGlueTable`
    # - `AWSRAMPermissionGlueDatabaseReadWriteForTable`
    # - `AWSRAMPermissionGlueTableReadWrite`
    # - `AWSRAMPermissionLFTagGlueDatabaseReadWriteForTable`
    # - `AWSRAMPermissionLFTagGlueTableReadWrite`
    permissions = optional(set(string), ["AWSRAMDefaultPermissionGlueTable"])

    external_principals_allowed = optional(bool, false)
    principals                  = optional(set(string), [])

    tags = optional(map(string), {})
  }))
  default  = []
  nullable = false
}

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
