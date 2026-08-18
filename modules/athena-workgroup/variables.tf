variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) The name of the workgroup."
  type        = string
  nullable    = false
}

variable "description" {
  description = "(Optional) The description of the workgroup. Defaults to `Managed by Terraform.`."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}

variable "enabled" {
  description = "(Optional) Whether to enable the workgroup. Defaults to `true`."
  type        = bool
  default     = true
  nullable    = false
}

variable "force_destroy" {
  description = "(Optional) Whether to delete the workgroup and its contents even if the workgroup contains any named queries. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "analytics_engine" {
  description = <<EOF
  (Optional) The configuration for the Athena engine version. An `analytics_engine` block as defined below.
    (Optional) `version` - The engine version for the workgroup. Valid values are `AUTO`, `ATHENA_V3`, `PYSPARK_V3` and `SPARK_V3.5`. Defaults to `AUTO`.
  EOF
  type = object({
    version = optional(string, "AUTO")
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["AUTO", "ATHENA_V3", "PYSPARK_V3", "SPARK_V3.5"], var.analytics_engine.version)
    error_message = "Valid values for `analytics_engine.version` are `AUTO`, `ATHENA_V3`, `PYSPARK_V3` and `SPARK_V3.5`."
  }
}

variable "customer_content_encryption" {
  description = <<EOF
  (Optional) A configurations for encrypting data stores such as notebooks and calculation code used by Athena for Apache Spark workgroups. Only supported if `analytics_engine.version` is `PYSPARK_V3`. A `customer_content_encryption` block as defined below.
    (Optional) `enabled` - Whether to encrypt the data stores with a customer managed KMS key. An AWS owned key is used if disabled. Defaults to `false`.
    (Optional) `kms_key` - The KMS key ARN used to encrypt the data stores. Required if `enabled` is `true`.
  EOF
  type = object({
    enabled = optional(bool, false)
    kms_key = optional(string)
  })
  default  = {}
  nullable = false

  validation {
    condition = anytrue([
      !var.customer_content_encryption.enabled,
      var.customer_content_encryption.enabled && var.customer_content_encryption.kms_key != null,
    ])
    error_message = "When `customer_content_encryption.enabled` is `true`, `customer_content_encryption.kms_key` is required."
  }
}

variable "logging" {
  description = <<EOF
  (Optional) A configurations for logging of Apache Spark workgroups. Only supported if you use Apache Spark engine types. A `logging` block as defined below.
    (Optional) `cloudwatch` - A configurations for delivering logs to Amazon CloudWatch Logs. `cloudwatch` as defined below.
      (Optional) `enabled` - Whether to enable CloudWatch logging. Defaults to `false`.
      (Optional) `log_group` - The name of the CloudWatch log group.
      (Optional) `log_stream_name_prefix` - The prefix of the CloudWatch log stream name.
      (Optional) `log_types` - A map of worker types to log types. For example, `SPARK_DRIVER = ["STDOUT", "STDERR"]`.
    (Optional) `managed` - A configurations for Athena managed log persistence. `managed` as defined below.
      (Optional) `enabled` - Whether to enable managed log persistence. Defaults to `true`.
      (Optional) `sse_kms_key` - The KMS key ARN used to encrypt the logs stored in managed log persistence.
    (Optional) `s3_bucket` - A configurations for delivering logs to Amazon S3. `s3_bucket` as defined below.
      (Optional) `enabled` - Whether to enable Amazon S3 logging. Defaults to `false`.
      (Optional) `location` - The Amazon S3 destination URI for log publishing. Required if `s3_bucket.enabled` is `true`.
      (Optional) `sse_kms_key` - The KMS key ARN used to encrypt the logs published to the given Amazon S3 destination.
  EOF
  type = object({
    cloudwatch = optional(object({
      enabled                = optional(bool, false)
      log_group              = optional(string)
      log_stream_name_prefix = optional(string)
      log_types              = optional(map(list(string)), {})
    }), {})
    managed = optional(object({
      enabled     = optional(bool, true)
      sse_kms_key = optional(string)
    }), {})
    s3_bucket = optional(object({
      enabled     = optional(bool, false)
      location    = optional(string, "")
      sse_kms_key = optional(string)
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition = anytrue([
      !var.logging.s3_bucket.enabled,
      var.logging.s3_bucket.enabled && startswith(var.logging.s3_bucket.location, "s3://"),
    ])
    error_message = "`logging.s3_bucket.location` is required and must start with `s3://` when `logging.s3_bucket.enabled` is `true`."
  }
}

variable "default_spark_execution_role" {
  description = <<EOF
  (Optional) A configurations for default IAM Role to be used by Athena to access user resources in Apache Spark sessions. Use `spark_execution_role` if `default_spark_execution_role.enabled` is `false`. Only supported if you use Apache Spark engine types. A `default_spark_execution_role` block as defined below.
    (Optional) `enabled` - Whether to create default IAM Role for Apache Spark workgroups. Defaults to `true`.
    (Optional) `name` - The name of the IAM Role. If not provided, a name will be generated using the module name and instance name.
    (Optional) `path` - The path for the IAM Role. Defaults to `/`.
    (Optional) `description` - The description of the IAM Role. Defaults to `Managed by Terraform.`.
    (Optional) `policies` - A list of IAM Policy ARNs to attach to the IAM Role. Defaults to an empty list.
    (Optional) `inline_policies` - A map of names to inline policy documents to attach to the IAM Role. Defaults to an empty map.
    (Optional) `permissions_boundary` - The ARN of the IAM policy to use as permissions boundary for the default IAM Role.
  EOF
  type = object({
    enabled              = optional(bool, true)
    name                 = optional(string)
    path                 = optional(string, "/")
    description          = optional(string, "Managed by Terraform.")
    policies             = optional(list(string), [])
    inline_policies      = optional(map(string), {})
    permissions_boundary = optional(string)
  })
  default  = {}
  nullable = false
}

variable "spark_execution_role" {
  description = "(Optional) The Amazon Resource Name (ARN) of the IAM Role to be used by Athena to access user resources in Apache Spark sessions. Only supported if you use Apache Spark engine types. Only required if `default_spark_execution_role.enabled` is `false`."
  type        = string
  default     = null
  nullable    = true
}

variable "query_result" {
  description = <<EOF
  (Optional) The configuration for query result location and encryption. Only required if you use Apache Spark engine types. `query_result` block as defined below.
    (Optional) `management_mode` - The mode of query result management. Valid values are `CUSTOMER_MANAGED` and `ATHENA_MANAGED`. Defaults to `ATHENA_MANAGED`.
      `CUSTOMER_MANAGED` - You manage the storage for your query results and keep the results as long as you require.
      `ATHENA_MANAGED` - Athena manages the storage for your queries and retains query results for 24 hours.
    (Optional) `override_client_config` - Whether to override client-side settings. Defaults to `true`.
    (Optional) `s3_access_grants` - A configurations for Amazon S3 Access Grants to control access to the query result location. Only supported if `iam_identity_center.enabled` is `true`. `s3_access_grants` as defined below.
      (Optional) `enabled` - Whether to enable Amazon S3 Access Grants for query results. Defaults to `false`.
      (Optional) `authentication_type` - The authentication type used for Amazon S3 Access Grants. Valid values are `DIRECTORY_IDENTITY`. Defaults to `DIRECTORY_IDENTITY`.
      (Optional) `user_level_prefix_enabled` - Whether to append the user ID as an Amazon S3 path prefix to the query result output location. This keeps query results of each user in the workgroup isolated from other users. Require `override_client_config` to be `true`. Defaults to `false`.
    (Optional) `athena_managed_query_result` - A configurations for Athena managed query result. `athena_managed_query_result` as defined below.
      (Optional) `encryption` - A configurations for encryption of Athena managed query result. `encryption` as defined below.
        (Optional) `kms_key` - The KMS key Amazon Resource Name (ARN) used to encrypt the query results.
    (Optional) `customer_managed_query_result` - A configurations for Customer managed query result. `customer_managed_query_result` as defined below.
      (Optional) `s3_bucket` - A configurations for S3 bucket used to store the query result. `s3_bucket` as defined below.
        (Required) `name` - The name of the S3 bucket used to store the query result.
        (Optional) `key_prefix` - The key prefix for the specified S3 bucket.
        (Optional) `expected_bucket_owner` - The AWS account ID that you expect to be the owner of the Amazon S3 bucket.
        (Optional) `bucket_owner_full_control_enabled` - Whether to grant the owner of the S3 query results bucket full control over the query results. This means that if your query result location is owned by another account, you grant full control over your query results to the other account. Defaults to `false`.
      (Optional) `encryption` - A configurations for encryption of Customer managed query result. `encryption` as defined below.
        (Optional) `enabled` - Whether to encrypt query results on S3 bucket. Defaults to `false`.
        (Optional) `mode` - The encryption mode to use. Valid values are `SSE_S3`, `SSE_KMS` and `CSE_KMS`. Defaults to `SSE_S3`.
          `SSE_S3` - Server-side encryption with Amazon S3-managed keys.
          `SSE_KMS` - Server-side encryption with KMS-managed keys.
          `CSE_KMS` - Client-side encryption with KMS-managed keys.
        (Optional) `kms_key` - The KMS key Amazon Resource Name (ARN) used to encrypt the query results. Required if `mode` is set to `SSE_KMS` or `CSE_KMS`.
        (Optional) `minimum_encryption_level_enforced` - Whether to enforce minimum encryption level for query results. Only effective when `override_client_config` is `false`, because the enforced workgroup configuration takes precedence over this flag. Defaults to `false`.
  EOF
  type = object({
    management_mode        = optional(string, "ATHENA_MANAGED")
    override_client_config = optional(bool, true)
    s3_access_grants = optional(object({
      enabled                   = optional(bool, false)
      authentication_type       = optional(string, "DIRECTORY_IDENTITY")
      user_level_prefix_enabled = optional(bool, false)
    }), {})
    athena_managed_query_result = optional(object({
      encryption = optional(object({
        kms_key = optional(string, null)
      }), {})
    }), {})
    customer_managed_query_result = optional(object({
      s3_bucket = object({
        name                              = string
        key_prefix                        = optional(string, "")
        expected_bucket_owner             = optional(string)
        bucket_owner_full_control_enabled = optional(bool, false)
      })
      encryption = optional(object({
        enabled                           = optional(bool, false)
        mode                              = optional(string, "SSE_S3")
        kms_key                           = optional(string, null)
        minimum_encryption_level_enforced = optional(bool, false)
      }), {})
    }))
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["CUSTOMER_MANAGED", "ATHENA_MANAGED"], var.query_result.management_mode)
    error_message = "Valid values for `query_result.management_mode` are `CUSTOMER_MANAGED` and `ATHENA_MANAGED`."
  }
  validation {
    condition     = contains(["DIRECTORY_IDENTITY"], var.query_result.s3_access_grants.authentication_type)
    error_message = "Valid values for `query_result.s3_access_grants.authentication_type` are `DIRECTORY_IDENTITY`."
  }
  validation {
    condition = anytrue([
      !var.query_result.s3_access_grants.user_level_prefix_enabled,
      var.query_result.s3_access_grants.user_level_prefix_enabled && var.query_result.override_client_config,
    ])
    error_message = "When `query_result.s3_access_grants.user_level_prefix_enabled` is `true`, `query_result.override_client_config` should be `true`."
  }
  validation {
    condition = anytrue([
      var.query_result.management_mode != "CUSTOMER_MANAGED",
      (var.query_result.management_mode == "CUSTOMER_MANAGED"
        && contains(["SSE_S3", "SSE_KMS", "CSE_KMS"], var.query_result.customer_managed_query_result.encryption.mode)
      )
    ])
    error_message = "Valid values for `encryption.mode` are `SSE_S3`, `SSE_KMS` and `CSE_KMS`."
  }
  validation {
    condition = anytrue([
      var.query_result.management_mode != "CUSTOMER_MANAGED",
      (var.query_result.management_mode == "CUSTOMER_MANAGED"
        && !startswith(var.query_result.customer_managed_query_result.s3_bucket.key_prefix, "/")
      )
    ])
    error_message = "`s3_bucket.key_prefix` cannot start with `/`."
  }
  validation {
    condition = anytrue([
      var.query_result.management_mode != "CUSTOMER_MANAGED",
      (var.query_result.management_mode == "CUSTOMER_MANAGED"
        && endswith(var.query_result.customer_managed_query_result.s3_bucket.key_prefix, "/")
      )
    ])
    error_message = "`s3_bucket.key_prefix` must end with `/`."
  }
}

variable "iam_identity_center" {
  description = <<EOF
  (Optional) The configuration for IAM Identity Center authentication. An `iam_identity_center` block as defined below.
    (Optional) `enabled` - Whether to enable IAM Identity Center authentication for the workgroup. Defaults to `false`.
    (Optional) `instance` - The Amazon Resource Name (ARN) of the IAM Identity Center instance to use for authentication.
    (Optional) `default_service_role` - A configurations for default IAM Role to be used by workgroup members authenticated via IAM Identity Center. Use `service_role` if `default_service_role.enabled` is `false`. `default_service_role` as defined below.
      (Optional) `enabled` - Whether to create default IAM Role for workgroup members authenticated via IAM Identity Center. Defaults to `true`.
      (Optional) `name` - The name of the IAM Role. If not provided, a name will be generated using the module name and instance name.
      (Optional) `path` - The path for the IAM Role. Defaults to `/`.
      (Optional) `description` - The description of the IAM Role. Defaults to `Managed by Terraform.`.
      (Optional) `policies` - A list of IAM Policy ARNs to attach to the IAM Role. Defaults to an empty list.
      (Optional) `inline_policies` - A map of names to inline policy documents to attach to the IAM Role. Defaults to an empty map.
      (Optional) `permissions_boundary` - The ARN of the IAM policy to use as permissions boundary for the default IAM Role.
    (Optional) `service_role` - The Amazon Resource Name (ARN) of the IAM Role to be used by workgroup members authenticated via IAM Identity Center. Only required if `default_service_role.enabled` is `false`.
  EOF
  type = object({
    enabled  = optional(bool, false)
    instance = optional(string)
    default_service_role = optional(object({
      enabled              = optional(bool, true)
      name                 = optional(string)
      path                 = optional(string, "/")
      description          = optional(string, "Managed by Terraform.")
      policies             = optional(list(string), [])
      inline_policies      = optional(map(string), {})
      permissions_boundary = optional(string)
    }), {})
    service_role = optional(string)
  })
  default  = {}
  nullable = false

  validation {
    condition = anytrue([
      !var.iam_identity_center.enabled,
      var.iam_identity_center.enabled && var.query_result.management_mode == "CUSTOMER_MANAGED"
    ])
    error_message = "When `iam_identity_center.enabled` is `true`, `query_result.management_mode` should be `CUSTOMER_MANAGED`."
  }
  validation {
    condition     = !var.query_result.s3_access_grants.enabled || var.iam_identity_center.enabled
    error_message = "When `query_result.s3_access_grants.enabled` is `true`, `iam_identity_center.enabled` should be `true`."
  }
}

variable "cloudwatch_metrics_enabled" {
  description = "(Optional) Whether Amazon CloudWatch metrics are enabled for the workgroup. Defaults to `true`."
  type        = bool
  default     = true
  nullable    = false
}

variable "query_on_s3_requester_pays_bucket_enabled" {
  description = "(Optional) Whether to allow members assigned to a workgroup to reference Amazon S3 Requester Pays buckets in queries. If set to false, workgroup members cannot query data from Requester Pays buckets, and queries that retrieve data from Requester Pays buckets cause an error. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "per_query_data_usage_limit" {
  description = "(Optional) Sets the limit in bytes for the maximum amount of data a query is allowed to scan. You can set only one per query limit for a workgroup. The limit applies to all queries in the workgroup and if query exceeds the limit, it will be cancelled. Minimum limit is 10 MB and maximum limit is 7EB per workgroup. Only supported if you use Athena SQL engine types."
  type        = number
  default     = null
  nullable    = true
}

variable "prepared_statements" {
  description = <<EOF
  (Optional) A list of prepared statements to reuse later. Only supported if you use Athena SQL engine types. A `prepared_statements` block as defined below.
    (Required) `name` - The name of the prepared statement. Maximum length of 256.
    (Optional) `description` - A brief explanation of the prepared statements. Defaults to `Managed by Terraform.`.
    (Required) `query` - The query string for the prepared statement.
  EOF
  type = list(object({
    name        = string
    description = optional(string, "Managed by Terraform.")

    query = string
  }))
  default  = []
  nullable = false
}

variable "named_queries" {
  description = <<EOF
  (Optional) A list of named queries to reuse later. Only supported if you use Athena SQL engine types. A `named_queries` block as defined below.
    (Required) `name` - The plain language name for the query. Maximum length of 128.
    (Optional) `description` - A brief explanation of the query. Defaults to `Managed by Terraform.`.
    (Required) `database` - The database to which the query belongs.
    (Required) `query` - The text of the query itself. In other words, all query statements. Maximum length of 262144.
  EOF
  type = list(object({
    name        = string
    description = optional(string, "Managed by Terraform.")

    database = string
    query    = string
  }))
  default  = []
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
