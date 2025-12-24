variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "catalog" {
  description = "(Optional) The ID of the Data Catalog in which to set the security configuration for. If omitted, this defaults to the AWS Account ID."
  type        = string
  default     = null
  nullable    = true
}

variable "policy" {
  description = "(Optional) The policy to be applied to the aws glue data catalog for access control."
  type        = string
  default     = ""
  nullable    = false
}

variable "encryption_for_connection_passwords" {
  description = <<EOF
  (Optional) A configuration to encrypt connection passwords in the data catalog. When enabled, the password you provide when you create a connection is encrypted with the given AWS KMS key. `encryption_for_connection_passwords` as defined below.
    (Optional) `enabled` - Whether to enable encryption for connection passwords. When set to `true`, passwords remain encrypted in the responses of `GetConnection` and `GetConnections`. This encryption takes effect independently of the catalog encryption. Defaults to `false`.
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
  (Optional) A configuration to encrypt at rest in the data catalog. When enabled, metadata stored in the data catalog is encrypted at rest. `encryption_at_rest` as defined below.
    (Optional) `enabled` - Whether to enable encryption at rest. Defaults to `false`.
    (Optional) `mode` - The encryption mode to use for encrypting data at rest. Valid values are `SSE-KMS` or `SSE-KMS-WITH-SERVICE-ROLE`. Defaults to `SSE-KMS`.
    (Optional) `kms_key` - The ID of AWS KMS key used for the encryption.
    (Optional) `service_role` - The service role to use when `mode` is set to `SSE-KMS-WITH-SERVICE-ROLE`.
  EOF
  type = object({
    enabled      = optional(bool, false)
    mode         = optional(string, "SSE-KMS")
    kms_key      = optional(string)
    service_role = optional(string)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["SSE-KMS", "SSE-KMS-WITH-SERVICE-ROLE"], var.encryption_at_rest.mode)
    error_message = "Valid values for `encryption_at_rest.mode` are `SSE-KMS` or `SSE-KMS-WITH-SERVICE-ROLE`."
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
