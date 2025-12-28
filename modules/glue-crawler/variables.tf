variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) The name of the crawler. Can be up to 255 characters long. Some character set including control characters are prohibited."
  type        = string
  nullable    = false
}

variable "description" {
  description = "(Optional) The description of the crawler. Can be up to 2048 characters long."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}

variable "configuration" {
  description = "(Optional) The configuration information of the crawler as JSON string. This versioned JSON string allows users to specify aspects of a crawler's behavior."
  type        = string
  default     = ""
  nullable    = false
}

variable "data_lineage_enabled" {
  description = "(Optional) Whether data lineage is enabled for the crawler. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "destination" {
  description = <<EOF
  (Required) A configuration of the Glue database where results are written. `destination` as defined below.
    (Required) `database` - The Glue database where results are written.
    (Optional) `table_prefix` - The table prefix used for catalog tables that are created. This prefix will be added to table names.
  EOF
  type = object({
    database     = string
    table_prefix = optional(string, "")
  })
  nullable = false
}

variable "custom_classifiers" {
  description = "(Optional) A set of custom classifiers to use with this crawler. A classifier checks whether a given file is in a format the crawler can handle. If it is, the classifier creates a schema in the form of a StructType object that matches that data format. By default, all AWS classifiers are included in a crawl, but these custom classifiers always override the default classifiers for a given classification."
  type        = set(string)
  default     = []
  nullable    = false
}

variable "catalog_data_sources" {
  description = <<EOF
  (Optional) A list of Glue Data Catalog data sources to be scanned by the crawler. Each item of `catalog_data_sources` as defined below.
    (Required) `database` - The name of the Glue Catalog database to be synchronized.
    (Required) `tables` - A list of one or more Glue Catalog tables to be synchronized.
    (Optional) `connection` - The name of the connection to use to connect to the Glue Data Catalog data source. Note that only one Catalog data source is allowed for Catalog Crawlers with a VPC connection.
    (Optional) `event_mode` - A configuration for event subscriptions of S3 data source which rely on Amazon S3 events to control what folders to crawl. Only required if you configured `recrawl_behavior` to `CRAWL_EVENT_MODE`.
      (Required) `sqs_queue` - The SQS ARN to use for identifying changes to crawl.
      (Optional) `sqs_dead_letter_queue` - The dead-letter SQS ARN for unprocessed messages.
  EOF
  type = list(object({
    database   = string
    tables     = set(string)
    connection = optional(string)

    event_mode = optional(object({
      sqs_queue             = string
      sqs_dead_letter_queue = optional(string)
    }))
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for source in var.catalog_data_sources :
      length(source.tables) > 0
    ])
    error_message = "One or more Glue Catalog tables are required for `tables`."
  }
}

variable "delta_lake_data_sources" {
  description = <<EOF
  (Optional) A list of Delta Lake data sources to be scanned by the crawler. Each item of `delta_lake_data_sources` as defined below.
    (Required) `paths` - A list of the Amazon S3 paths to the Delta tables.
    (Optional) `connection` - The name of the connection to use to connect to the Delta Lake data source.
    (Optional) `table_type` - How you want to create the Delta Lake tables. Valid values are `NATIVE_TABLES` and `SYMLINK_TABLES`. Defaults to `NATIVE_TABLES`.
      `NATIVE_TABLES` - Allow integration with query engines that support querying of the Delta transaction log directly.
      `SYMLINK_TABLES` - Create a symlink manifest folder with manifest files partitioned by the partition keys, based on the specified configuration parameters.
    (Optional) `write_manifest` - Whether to write the manifest files to the Delta table path. When enabled, if the crawler detects table metadata or schema changes in the Delta Lake transaction log, it regenerates the manifest file. You should not choose this option if you configured automatic manifest updates with Delta Lake `SET TBLPROPERTIES`. Defaults to `false`.
  EOF
  type = list(object({
    paths      = list(string)
    connection = optional(string)

    table_type     = optional(string, "NATIVE_TABLES")
    write_manifest = optional(bool, false)
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for source in var.delta_lake_data_sources :
      contains(["NATIVE_TABLES", "SYMLINK_TABLES"], source.table_type)
    ])
    error_message = "Valid values for `table_type` are `NATIVE_TABLES` and `SYMLINK_TABLES`."
  }
}

variable "dynamodb_data_sources" {
  description = <<EOF
  (Optional) A list of DynamoDB data sources to be scanned by the crawler. Each item of `dynamodb_data_sources` as defined below.
    (Required) `path` - The name of the DynamoDB table to crawl.
    (Optional) `scanning_rate` - The percentage of the configured DynamoDB table Read Capacity Units to be used by the AWS Glue crawler. The valid values are between `0.1` to `1.5`. If not specified, defaults to `0.5`% for provisioned tables and 1/4 of maximum configured capacity for On-Demand tables.
    (Optional) `data_sampling_enabled` - Whether to scan all the records, or to sample rows from the table. Scanning all the records can take a long time when the table is not a high throughput table. Defaults to `true`.
  EOF
  type = list(object({
    path = string

    scanning_rate         = optional(number)
    data_sampling_enabled = optional(bool, true)
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for source in var.dynamodb_data_sources :
      alltrue([
        source.scanning_rate >= 0.1,
        source.scanning_rate <= 1.5,
      ])
      if source.scanning_rate != null
    ])
    error_message = "Valid values for `scanning_rate` are between `0.1` to `1.5`."
  }
}

variable "jdbc_data_sources" {
  description = <<EOF
  (Optional) A list of JDBC data sources to be scanned by the crawler. Each item of `jdbc_data_sources` as defined below.
    (Required) `path` - The path of the JDBC data source. Use `<database>/<schema>/<table>` or `<database>/<table>` format, depending on the database product. Oracle Database and MySQL don’t support schema in the path. You can substitute the percent `%` character for `<schema>` or `<table>`. For example, for an Oracle database with a system identifier (SID) of orcl, enter `orcl/%` to import all tables to which the user named in the connection has access.
    (Optional) `connection` - The name of the connection to use to connect to the JDBC data source.
    (Optional) `exclusion_patterns` - A list of glob patterns used to exclude from the crawl.
    (Optional) `additional_metadata_properties` - A set of additional metadata properties for the crawler to crawl. Valid values are `RAWTYPES` and `COMMENTS` to enable additional metadata in table responses.
      `RAWTYPES` - Persist the raw datatypes of the table columns in additional metadata. As a default behavior, the crawler translates the raw datatypes to Hive-compatible types.
      `COMMENTS` - Crawl associated table level and column level comments.
  EOF
  type = list(object({
    path       = string
    connection = optional(string)

    exclusion_patterns             = optional(list(string), [])
    additional_metadata_properties = optional(set(string), [])
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for source in var.jdbc_data_sources :
      alltrue([
        for property in source.additional_metadata_properties :
        contains(["RAWTYPES", "COMMENTS"], property)
      ])
    ])
    error_message = "Valid values for `additional_metadata_properties` are `RAWTYPES` and `COMMENTS`."
  }
}

variable "mongodb_data_sources" {
  description = <<EOF
  (Optional) A list of MongoDB data sources to be scanned by the crawler. Each item of `mongodb_data_sources` as defined below.
    (Required) `path` - The path of the Amazon DocumentDB or MongoDB data source (database/collection). Use `database/collection` format.
    (Optional) `connection` - The name of the connection to use to connect to the Amazon DocumentDB or MongoDB data source.
    (Optional) `data_sampling_enabled` - Whether to scan all the records, or to sample rows from the table. Scanning all the records can take a long time when the table is not a high throughput table. Defaults to `true`.
  EOF
  type = list(object({
    path       = string
    connection = optional(string)

    data_sampling_enabled = optional(bool, true)
  }))
  default  = []
  nullable = false
}

variable "s3_data_sources" {
  description = <<EOF
  (Optional) A list of S3 data sources to be scanned by the crawler. Each item of `s3_data_sources` as defined below.
    (Required) `path` - The path to the Amazon S3 data source.
    (Optional) `connection` - The name of a connection which allows crawler to access data in S3 within a VPC. Note that each crawler is limited to one Network connection so any other Amazon S3 targets will also use the same connection (or none, if left blank).
    (Optional) `exclusion_patterns` - A list of glob patterns used to exclude from the crawl.
    (Optional) `sample_size` - The number of files in each leaf folder to be crawled when crawling sample files in a dataset. If not set, all the files are crawled. A valid value is an integer between `1` and `249`.
    (Optional) `event_mode` - A configuration for event subscriptions of S3 data source which rely on Amazon S3 events to control what folders to crawl. Only required if you configured `recrawl_behavior` to `CRAWL_EVENT_MODE`.
      (Required) `sqs_queue` - The SQS ARN to use for identifying changes to crawl.
      (Optional) `sqs_dead_letter_queue` - The dead-letter SQS ARN for unprocessed messages.
  EOF
  type = list(object({
    path       = string
    connection = optional(string)

    exclusion_patterns = optional(list(string), [])
    sample_size        = optional(number)

    event_mode = optional(object({
      sqs_queue             = string
      sqs_dead_letter_queue = optional(string)
    }))
  }))
  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for source in var.s3_data_sources :
      alltrue([
        source.sample_size >= 1,
        source.sample_size <= 249,
      ])
      if source.sample_size != null
    ])
    error_message = "Valid value of `sample_size` is an integer between `1` and `249`."
  }
}

variable "schedule" {
  description = <<EOF
  (Optional) A configuration to schedule the crawler. `schedule` as defined below.
    (Optional) `type` - The schedule type. Valid values are `ON_DEMAND` and `CRON_EXPRESSION`. Defaults to `ON_DEMAND`.
      `ON_DEMAND` - The crawler runs only when explicitly started.
      `CRON_EXPRESSION` - The crawler runs at the time(s) specified in the `expression`.
    (Optional) `expression` - A cron expression used to specify the schedule. For example, to run something every day at 12:15 UTC, you would specify: `cron(15 12 * * ? *)`.
  EOF
  type = object({
    type       = optional(string, "ON_DEMAND")
    expression = optional(string, "")
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["ON_DEMAND", "CRON_EXPRESSION"], var.schedule.type)
    error_message = "Valid values for `schedule.type` are `ON_DEMAND` and `CRON_EXPRESSION`."
  }
  validation {
    condition = anytrue([
      var.schedule.type != "CRON_EXPRESSION",
      (var.schedule.type == "CRON_EXPRESSION" && length(var.schedule.expression) > 0),
    ])
    error_message = "`schedule.expression` is required when `schedule.type` is `CRON_EXPRESSION`."
  }
}

variable "recrawl_behavior" {
  description = <<EOF
  (Optional) A behavior type of the crawler whether to crawl the entire dataset again, or to crawl only folders that were added since the last crawler run, or crawl what S3 notifies the crawler of via SQS. Valid Values are `CRAWL_EVERYTHING`, `CRAWL_EVENT_MODE` and `CRAWL_NEW_FOLDERS_ONLY`. Defaults to `CRAWL_EVERYTHING`.

    `CRAWL_EVERYTHING` - Crawl all folders again with every subsequent crawl.
    `CRAWL_EVENT_MODE` - Rely on Amazon S3 events to control what folders to crawl.
    `CRAWL_NEW_FOLDERS_ONLY` - Only Amazon S3 folders that were added since the last crawl will be crawled. If the schemas are compatible, new partitions will be added to existing tables.
  EOF
  type        = string
  default     = "CRAWL_EVERYTHING"
  nullable    = false

  validation {
    condition     = contains(["CRAWL_EVERYTHING", "CRAWL_EVENT_MODE", "CRAWL_NEW_FOLDERS_ONLY"], var.recrawl_behavior)
    error_message = "Valid values for `recrawl_behavior` are `CRAWL_EVERYTHING`, `CRAWL_EVENT_MODE`, `CRAWL_NEW_FOLDERS_ONLY`."
  }
}

variable "schema_change_policy" {
  description = <<EOF
  (Optional) A configuration of the crawler's schema change policy. `schema_change_policy` as defined below.
    (Optional) `delete_behavior` - The deletion behavior when the crawler finds a deleted object. Valid values are `LOG`, `DELETE_FROM_DATABASE` and `DEPRECATE_IN_DATABASE`. Defaults to `DEPRECATE_IN_DATABASE`.

      `LOG` - Ignore the change and don't update the table in the data catalog.
      `DELETE_FROM_DATABASE` - Delete tables and partitions from the data catalog.
      `DEPRECATE_IN_DATABASE` - Mark the table as deprecated in the data catalog. If you run a job that references a deprecated table, the job might fail. Edit jobs that reference deprecated tables to remove them as sources and targets. We recommend that you delete deprecated tables when they are no longer needed.
    (Optional) `update_behavior` - The update behavior when the crawler finds a changed schema. Valid values: `LOG` and `UPDATE_IN_DATABASE`. Defaults to `UPDATE_IN_DATABASE`.

      `LOG` - Ignore the change and don't update the table in the data catalog.
      `UPDATE_IN_DATABASE` - Update the table definition in the data catalog.
  EOF
  type = object({
    delete_behavior = optional(string, "DEPRECATE_IN_DATABASE")
    update_behavior = optional(string, "UPDATE_IN_DATABASE")
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["LOG", "DELETE_FROM_DATABASE", "DEPRECATE_IN_DATABASE"], var.schema_change_policy.delete_behavior)
    error_message = "Valid values for `schema_change_policy.delete_behavior` are `LOG`, `DELETE_FROM_DATABASE`, `DEPRECATE_IN_DATABASE`."
  }
  validation {
    condition     = contains(["LOG", "UPDATE_IN_DATABASE"], var.schema_change_policy.update_behavior)
    error_message = "Valid values for `schema_change_policy.update_behavior` are `LOG`, `UPDATE_IN_DATABASE`."
  }
}

variable "default_service_role" {
  description = <<EOF
  (Optional) A configuration for the default service role used by the crawler to access other resources. Use `service_role` if `default_service_role.enabled` is `false`. `default_service_role` as defined below.
    (Optional) `enabled` - Whether to create the default service role. Defaults to `true`.
    (Optional) `name` - The name of the default service role. Defaults to `glue-crawler-$${var.name}`.
    (Optional) `path` - The path of the default service role. Defaults to `/`.
    (Optional) `description` - The description of the default service role.
    (Optional) `policies` - A list of IAM policy ARNs to attach to the default service role. `AWSGlueServiceRole` is always attached. Defaults to `[]`.
    (Optional) `inline_policies` - A Map of inline IAM policies to attach to the default service role. (`name` => `policy`).
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string)
    path        = optional(string, "/")
    description = optional(string, "Managed by Terraform.")

    policies        = optional(list(string), [])
    inline_policies = optional(map(string), {})
  })
  default  = {}
  nullable = false
}

variable "service_role" {
  description = "(Optional) The ARN (Amazon Resource Name) of the IAM Role used by the crawler to access other resources. Only required if `default_service_role.enabled` is `false`."
  type        = string
  default     = null
  nullable    = true
}

variable "security_configuration" {
  description = "(Optional) The name of Security Configuration to be used by the crawler. Use to enable at-rest encryption on the logs pushed to CloudWatch."
  type        = string
  default     = ""
  nullable    = false
}

variable "lake_formation_credentials" {
  description = <<EOF
  (Optional) A configuration of the crawler to use Lake Formation credentials for crawling the data source. `lake_formation_credentials` as defined below.
    (Optional) `enabled` - Whether to use Lake Formation credentials for the crawler instead of the IAM role credentials. Defaults to `false`.
    (Optional) `account_id` - A valid AWS account ID for cross account crawls. If the data source is registered in another account, you must provide the registered account ID. Otherwise, the crawler will crawl only those data sources associated to the account.
  EOF
  type = object({
    enabled    = optional(bool, false)
    account_id = optional(string, null)
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
