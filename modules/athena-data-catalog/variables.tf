variable "name" {
  description = "(Required) The name of the data catalog. The catalog name must be unique for the AWS account and can use a maximum of 128 alphanumeric, underscore, at sign, or hyphen characters."
  type        = string
  nullable    = false
}

variable "description" {
  description = "(Optional) The description of the data catalog."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}

variable "type" {
  description = <<EOF
  (Required) A type of the data catalog. Valid values are `LAMBDA`, `GLUE`, `HIVE`.
    - `LAMBDA` for a federated catalog.
    - `GLUE` for an AWS Glue Data Catalog.
    - `HIVE` for an external hive metastore.
  EOF
  type        = string
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
