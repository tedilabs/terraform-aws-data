variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "catalog" {
  description = "(Optional) The ID of the Data Catalog in which to create the table. If omitted, this defaults to the AWS Account ID."
  type        = string
  default     = null
  nullable    = true
}

variable "database" {
  description = "(Required) The name of the metadata database where the table metadata resides. For Hive compatibility, this name must be all lowercase."
  type        = string
  nullable    = false
}

variable "owner" {
  description = "(Optional) The table owner. Included for Apache Hive compatibility. Not used in the normal course of Glue operations."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) The name of the table. For Hive compatibility, this must be entirely lowercase."
  type        = string
  nullable    = false
}

variable "description" {
  description = "(Optional) The description of the table. Defaults to `Managed by Terraform.`."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}

variable "type" {
  description = <<EOF
  (Optional) The type of this table. AWS Glue will create tables with the `EXTERNAL_TABLE` type. Valid values are `EXTERNAL_TABLE`, `GOVERNED`. Defaults to `EXTERNAL_TABLE`.

  `EXTERNAL_TABLE` - Hive compatible attribute, indicates a non-Hive managed table.
  `GOVERNED` - Used by AWS Lake Formation. The AWS Glue Data Catalog understands `GOVERNED`.
  EOF
  type        = string
  default     = "EXTERNAL_TABLE"
  nullable    = false

  # INFO: Need to clarify valid values for `type` variable
  # validation {
  #   condition     = contains(["EXTERNAL_TABLE", "GOVERNED"], var.type)
  #   error_message = "Valid values for `type` are `EXTERNAL_TABLE` or `GOVERNED`."
  # }
}

variable "location" {
  description = "(Optional) The physical location of the table. By default, this takes the form of the warehouse location, followed by the database location in the warehouse, followed by the table name."
  type        = string
  default     = null
  nullable    = true
}

variable "input_format" {
  description = <<EOF
  (Optional) Absolute class name of the Hadoop `InputFormat` to use when reading table files. Supported values are following:
    `org.apache.hadoop.hive.ql.io.avro.AvroContainerInputFormat` - InputFormat for Avro files.
    `com.amazon.emr.cloudtrail.CloudTrailInputFormat` - InputFormat for Cloudtrail Logs.
    `org.apache.hadoop.hive.ql.io.orc.OrcInputFormat` - InputFormat for Orc files.
    `org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat` - InputFormat for Parquet files.
    `org.apache.hadoop.mapred.TextInputFormat` - An InputFormat for plain text files. Files are broken into lines. Either linefeed or carriage-return are used to signal end of line. Keys are the position in the file, and values are the line of text. JSON & CSV files are examples of this InputFormat.
  EOF
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition = contains([
      "",
      "org.apache.hadoop.hive.ql.io.avro.AvroContainerInputFormat",
      "com.amazon.emr.cloudtrail.CloudTrailInputFormat",
      "org.apache.hadoop.hive.ql.io.orc.OrcInputFormat",
      "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat",
      "org.apache.hadoop.mapred.TextInputFormat",
    ], var.input_format)
    error_message = "Supported values for `input_format` are `org.apache.hadoop.hive.ql.io.avro.AvroContainerInputFormat`, `com.amazon.emr.cloudtrail.CloudTrailInputFormat`, `org.apache.hadoop.hive.ql.io.orc.OrcInputFormat`, `org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat`, `org.apache.hadoop.mapred.TextInputFormat`."
  }
}

variable "output_format" {
  description = <<EOF
  (Optional) Absolute class name of the Hadoop `OutputFormat` to use when writing table files. Supported values are following:
    `org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat` - Writes text data with a null key (value only).
    `org.apache.hadoop.hive.ql.io.avro.AvroContainerOutputFormat` - OutputFormat for Avro files.
    `org.apache.hadoop.hive.ql.io.orc.OrcOutputFormat` - OutputFormat for Orc files.
    `org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat` - OutputFormat for Parquet files.
  EOF
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition = contains([
      "",
      "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat",
      "org.apache.hadoop.hive.ql.io.avro.AvroContainerOutputFormat",
      "org.apache.hadoop.hive.ql.io.orc.OrcOutputFormat",
      "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat",
    ], var.output_format)
    error_message = "Supported values for `output_format` are `org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat`, `org.apache.hadoop.hive.ql.io.avro.AvroContainerOutputFormat`, `org.apache.hadoop.hive.ql.io.orc.OrcOutputFormat`, `org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat`."
  }
}

variable "compressed" {
  description = "(Optional) Whether the data in the table is compressed. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "columns" {
  description = <<EOF
  (Optional) A list of the configurations for columns in the table. Each item of `columns` as defined below.
    (Required) `name` - The name of the Column.
    (Required) `type` - The data type of the Column.
    (Optional) `comment` - A free-form text comment.
    (Optional) `parameters` - A properties associated with the column, as a map of key-value pairs.
  EOF
  type = list(object({
    name       = string
    type       = string
    comment    = optional(string, "")
    parameters = optional(map(string), {})
  }))
  default  = []
  nullable = false
}

variable "ser_de" {
  description = <<EOF
  (Optional) A configuration of the SerDe (Serializer/Deserializer) of the table. `ser_de` as defined below.
    (Optional) `name` - The name of the SerDe.
    (Optional) `serialization_library` - Absolute class name of the SerDe library, which is used by the table for serialization and deserialization of rows. For example, `org.openx.data.jsonserde.JsonSerDe`.
    (Optional) `parameters` - A map of initialization parameters for the SerDe, in key-value form.
  EOF
  type = object({
    name                  = optional(string)
    serialization_library = optional(string)
    parameters            = optional(map(string), {})
  })
  default  = {}
  nullable = false
}

variable "partition_keys" {
  description = <<EOF
  (Optional) A list of columns by which the table is partitioned. Only primitive types are supported as partition keys. Each item of `partition_keys` as defined below.
    (Required) `name` - The name of the partition key.
    (Required) `type` - The data type of the partition key.
    (Optional) `comment` - A free-form text comment.
  EOF
  type = list(object({
    name    = string
    type    = string
    comment = optional(string, "")
  }))
  default  = []
  nullable = false
}

variable "parameters" {
  description = "(Optional) A properties associated with this table, as a map of key-value pairs."
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
