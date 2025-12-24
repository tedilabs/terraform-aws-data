variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "catalog" {
  description = "(Optional) The ID of the Data Catalog in which to create the database. If omitted, this defaults to the AWS Account ID."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) The name of the database. For Hive compatibility, this is folded to lowercase when it is stored. If you plan to access the database from Amazon Athena, then provide a name with only alphanumeric and underscore characters. The acceptable characters are lowercase letters, numbers, and the underscore character."
  type        = string
  nullable    = false
}

variable "description" {
  description = "(Optional) The description of the database."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}

variable "location_uri" {
  description = "(Optional) The location URI of the database. An S3 location is required for managed tables and Zero-ETL integrations."
  type        = string
  default     = ""
  nullable    = false
}

variable "parameters" {
  description = <<EOF
  (Optional) These key-value pairs define parameters and properties of the database.
  EOF
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "federated_database" {
  description = <<EOF
  (Optional) A configuration of federated database to reference an entity outside the AWS Glue Data Catalog. `federated_database` as defined below.
    (Optional) `id` - The unique ID for the federated database.
    (Optional) `connection` - The name of the connection to the external metastore.
  EOF
  type = object({
    id         = optional(string)
    connection = optional(string)
    # TODO:Support connection type
  })
  default  = null
  nullable = true
}

variable "target_database" {
  description = <<EOF
  (Optional) A configuration of a target database for resource linking. `target_database` as defined below.
    (Required) `catalog` - The ID of the Data Catalog in which the target database resides.
    (Optional) `region` - The region in which the target database resides. If omitted, this defaults to the provider's configured region.
    (Required) `database` - The name of the target database.
  EOF
  type = object({
    catalog  = string
    region   = optional(string)
    database = string
  })
  default  = null
  nullable = true
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
    # - `AWSRAMDefaultPermissionGlueDatabase`
    # - `AWSRAMPermissionGlueAllTablesReadWriteForDatabase`
    # - `AWSRAMPermissionGlueDatabaseReadWrite`
    # - `AWSRAMPermissionGlueTableReadWriteForDatabase`
    # - `AWSRAMPermissionLFTagGlueDatabaseReadWrite`
    # - `AWSRAMPermissionLFTagGlueTableReadWriteForDatabase`
    permissions = optional(set(string), ["AWSRAMDefaultPermissionGlueDatabase"])

    external_principals_allowed = optional(bool, false)
    principals                  = optional(set(string), [])

    tags = optional(map(string), {})
  }))
  default  = []
  nullable = false
}
