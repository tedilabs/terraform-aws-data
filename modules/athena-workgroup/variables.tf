variable "name" {
  description = "(Required) The name of the workgroup."
  type        = string
}

variable "description" {
  description = "(Optional) The description of the workgroup."
  type        = string
  default     = "Managed by Terraform."
}

variable "enabled" {
  description = "(Optional) "
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "(Optional) Whether to delete the workgroup and its contents even if the workgroup contains any named queries."
  type        = bool
  default     = false
}

variable "client_config_enabled" {
  description = "(Optional) Whether overriding workgroup configurations with client-side configurations is allowed. Defaults to `false`."
  type        = bool
  default     = false
}
variable "cloudwatch_metrics_enabled" {
  description = "(Optional) Whether Amazon CloudWatch metrics are enabled for the workgroup. Defaults to `true`."
  type        = bool
  default     = true
}

variable "query_on_s3_requester_pays_bucket_enabled" {
  description = "(Optional) Whether to allow members assigned to a workgroup to reference Amazon S3 Requester Pays buckets in queries. If set to false, workgroup members cannot query data from Requester Pays buckets, and queries that retrieve data from Requester Pays buckets cause an error. Defaults to `false`."
  type        = bool
  default     = false
}

variable "per_query_data_usage_limit" {
  description = "(Optional) Sets the limit in bytes for the maximum amount of data a query is allowed to scan. You can set only one per query limit for a workgroup. The limit applies to all queries in the workgroup and if query exceeds the limit, it will be cancelled. Minimum limit is 10 MB and maximum limit is 7EB per workgroup."
  type        = number
  default     = null
}

variable "query_result" {
  description = <<EOF
  (Optional) The configuration for query result location and encryption. A `query_result` block as defined below.
    (Required) `s3_bucket` - The name of the S3 bucket used to store the query result.
    (Optional) `s3_key_prefix` - The key prefix for the specified S3 bucket. Defaults to `null`.
    (Optional) `s3_bucket_expected_owner` - The AWS account ID that you expect to be the owner of the Amazon S3 bucket.
    (Optional) `s3_bucket_owner_full_control_enabled` - Enabling this option grants the owner of the S3 query results bucket full control over the query results. This means that if your query result location is owned by another account, you grant full control over your query results to the other account.
    (Optional) `encryption_enabled` - Whether to encrypt query results on S3 bucket.
    (Optional) `encryption_mode` - Indicates whether Amazon S3 server-side encryption with Amazon S3-managed keys (SSE_S3), server-side encryption with KMS-managed keys (SSE_KMS), or client-side encryption with KMS-managed keys (CSE_KMS) is used. If a query runs in a workgroup and the workgroup overrides client-side settings, then the workgroup's setting for encryption is used.
    (Optional) `encryption_kms_key` - For `SSE_KMS` and `CSE_KMS` encryption modes, this is the KMS key Amazon Resource Name (ARN).
  EOF
  type        = map(any)
  default     = null
}

variable "named_queries" {
  description = <<EOF
  (Optional) Save named queries to reuse later. A `named_queries` block as defined below.
    (Required) `name` - The plain language name for the query. Maximum length of 128.
    (Optional) `description` - A brief explanation of the query. Maximum length of 1024.
    (Required) `database` - The database to which the query belongs.
    (Required) `query` - The text of the query itself. In other words, all query statements. Maximum length of 262144.
  EOF
  type        = list(map(string))
  default     = []
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module informations."
  type        = bool
  default     = true
}


###################################################
# Resource Group
###################################################

variable "resource_group_enabled" {
  description = "(Optional) Whether to create Resource Group to find and group AWS resources which are created by this module."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "(Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`."
  type        = string
  default     = ""
}

variable "resource_group_description" {
  description = "(Optional) The description of Resource Group."
  type        = string
  default     = "Managed by Terraform."
}
