variable "catalog" {
  description = "(Optional) The ID of the Data Catalog in which to set the security configuration for. If omitted, this defaults to the AWS Account ID."
  type        = string
  default     = null
}

variable "policy" {
  description = "(Optional) The policy to be applied to the aws glue data catalog for access control."
  type        = string
  default     = ""
  nullable    = false
}

variable "encryption_for_connection_passwords" {
  description = <<EOF
  (Optional) A configuration to encrypt connection passwords in the data catalog. When enabled, the password you provide when you create a connection is encrypted with the given AWS KMS key.
    (Optional) `enabled` - Whether to enable encryption for connection passwords. Defaults to `false`.
    (Optional) `kms_key` - The ID of AWS KMS key used for the encryption. If connection password protection is enabled, the caller of `CreateConnection` and `UpdateConnection` needs at least `kms:Encrypt` permission on the specified KMS key, to encrypt passwords before storing them in the Data Catalog. You can set the decrypt permission to enable or restrict access on the password key according to your security requirements.
  EOF
  type = object({
    enabled = optional(bool, false)
    kms_key = optional(string)
  })
  default  = {}
  nullable = false
}

variable "encryption_at_rest" {
  description = <<EOF
  (Optional) A configuration to encrypt at rest in the data catalog. When enabled, metadata stored in the data catalog is encrypted at rest.
    (Optional) `enabled` - Whether to enable encryption at rest. Defaults to `false`.
    (Optional) `kms_key` - The ID of AWS KMS key used for the encryption.
  EOF
  type = object({
    enabled = optional(bool, false)
    kms_key = optional(string)
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


###################################################
# Resource Sharing by RAM (Resource Access Manager)
###################################################

variable "shares" {
  description = "(Optional) A list of resource shares via RAM (Resource Access Manager)."
  type = list(object({
    name = optional(string)

    # INFO
    # - `AWSRAMDefaultPermissionGlueCatalog`
    # - `AWSRAMPermissionGlueAllTablesReadWriteForCatalog`
    # - `AWSRAMPermissionGlueDatabaseReadWriteForCatalog`
    # - `AWSRAMPermissionGlueTableReadWriteForCatalog`
    # - `AWSRAMPermissionLFTagGlueDatabaseReadWriteForCatalog`
    # - `AWSRAMPermissionLFTagGlueTableReadWriteForCatalog`
    permissions = optional(set(string), ["AWSRAMDefaultPermissionGlueCatalog"])

    external_principals_allowed = optional(bool, false)
    principals                  = optional(set(string), [])

    tags = optional(map(string), {})
  }))
  default  = []
  nullable = false
}
