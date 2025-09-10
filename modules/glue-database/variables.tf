variable "catalog" {
  description = "(Optional) The ID of the Data Catalog in which to create the database. If omitted, this defaults to the AWS Account ID."
  type        = string
  default     = null
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
  description = "(Optional) The location of the database. For example, an HDFS path."
  type        = string
  default     = ""
  nullable    = false
}

variable "parameters" {
  description = <<EOF
  (Optional) A set of key value pairs that specifies the Lambda function or functions to use for creating the data catalog. The mapping used depends on the catalog type.

  `LAMBDA`
    Use one of the following sets of required parameters, but not both.
    - If you have one Lambda function that processes metadata and another for reading the actual data.
      (Required) `metadata-function` - The ARN of Lambda function to process metadata.
      (Required) `record-function` - The ARN of Lambda function to read the actual data.
    - If you have a composite Lambda function that processes both metadata and data.
      (Required) `function` - The ARN of a composite Lambda function to process both metadata and data.

  `GLUE`
    (Required) `catalog_id` - The account ID of the AWS account to which the Glue Data Catalog belongs.

  `HIVE`
    (Required) `metadata-function` - The ARN of Lambda function to process metadata.
    (Optional) `sdk-version` - Defaults to the currently supported version.
  EOF
  type        = map(string)
  default     = {}
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
