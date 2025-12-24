variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) The name of the data catalog. The catalog name must be unique for the AWS account and can use a maximum of 128 alphanumeric, underscore, at sign, or hyphen characters."
  type        = string
  nullable    = false
}

variable "description" {
  description = "(Optional) The description of the data catalog. Defaults to `Managed by Terraform.`."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}

variable "type" {
  description = <<EOF
  (Required) A type of the data catalog. Valid values are `LAMBDA`, `GLUE`, `HIVE` and `FEDERATED`.
    - `LAMBDA` for a federated catalog.
    - `GLUE` for an AWS Glue Data Catalog.
    - `HIVE` for an external hive metastore.
    - `FEDERATED` for a federated catalog for which Athena creates the connection and the Lambda function for you based on the parameters that you pass. For FEDERATED type, we do not support IAM identity center.
  EOF
  type        = string
  nullable    = false

  validation {
    condition     = contains(["LAMBDA", "GLUE", "HIVE", "FEDERATED"], var.type)
    error_message = "Invalid type. Valid values are `LAMBDA`, `GLUE`, `HIVE` and `FEDERATED`."
  }
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
    (Required) `catalog-id` - The account ID of the AWS account to which the Glue Data Catalog belongs.

  `HIVE`
    (Required) `metadata-function` - The ARN of Lambda function to process metadata.
    (Optional) `sdk-version` - Defaults to the currently supported version.

  `FEDERATED`
    Use one of the following sets of required parameters, but not both.
    - For an existing Glue connection.
      (Required) `connection-arn` - The ARN of the Glue connection to the data source.
    - For Athena to create a new connection.
      (Required) `connection-type` - The type of connection for a `FEDERATED` data catalog. Valid values are `DYNAMODB`, `MYSQL`, `POSTGRESQL`, `REDSHIFT`, `ORACLE`, `SYNAPSE`, `SQLSERVER`, `DB2`, `OPENSEARCH`, `BIGQUERY`, `GOOGLECLOUDSTORAGE`, `HBASE`, `DOCUMENTDB`, `CMDB`, `TPCDS`, `TIMESTREAM`, `SAPHANA`, `SNOWFLAKE`, `DATALAKEGEN2`, `DB2AS400`.
      (Required) `connection-properties` - A JSON string that contains the properties for the new connection. The required properties vary based on the `connection-type`.
  EOF
  type        = map(string)
  default     = {}
  nullable    = false

  validation {
    condition = anytrue([
      alltrue([
        for k, v in var.parameters :
        contains(["metadata-function", "record-function"], k)
        if var.type == "LAMBDA"
      ]),
      alltrue([
        for k, v in var.parameters :
        contains(["function"], k)
        if var.type == "LAMBDA"
      ]),
    ])
    error_message = "For type `LAMBDA`, either both `metadata-function` and `record-function` parameters or `function` parameter must be provided."
  }
  validation {
    condition = alltrue([
      for k, v in var.parameters :
      contains(["catalog-id"], k)
      if var.type == "GLUE"
    ])
    error_message = "For type `GLUE`, only `catalog-id` parameter is allowed."
  }
  validation {
    condition = alltrue([
      for k, v in var.parameters :
      contains(["metadata-function", "sdk-version"], k)
      if var.type == "HIVE"
    ])
    error_message = "For type `HIVE`, only `metadata-function` and `sdk-version` parameters are allowed."
  }
  validation {
    condition = anytrue([
      alltrue([
        for k, v in var.parameters :
        contains(["connection-arn"], k)
        if var.type == "FEDERATED"
      ]),
      alltrue([
        for k, v in var.parameters :
        contains(["connection-type", "connection-properties"], k)
        if var.type == "FEDERATED"
      ]),
    ])
    error_message = "For type `FEDERATED`, either `connection-arn` parameter or both `connection-type` and `connection-properties` parameters must be provided."
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
