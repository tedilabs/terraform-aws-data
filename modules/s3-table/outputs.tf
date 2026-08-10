output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_s3tables_table.this.region
}

output "table_bucket" {
  description = "The ARN of the table bucket that contains the table."
  value       = aws_s3tables_table.this.table_bucket_arn
}

output "namespace" {
  description = "The name of the namespace for the table."
  value       = aws_s3tables_table.this.namespace
}

output "name" {
  description = "The name of the table."
  value       = aws_s3tables_table.this.name
}

output "arn" {
  description = "The ARN of the table."
  value       = aws_s3tables_table.this.arn
}

output "format" {
  description = "The format of the table."
  value       = aws_s3tables_table.this.format
}

output "type" {
  description = "The type of the table. One of `customer` or `aws`."
  value       = aws_s3tables_table.this.type
}

output "owner" {
  description = "The account ID of the account that owns the table."
  value       = aws_s3tables_table.this.owner_account_id
}

output "created_at" {
  description = "Date and time when the table was created."
  value       = aws_s3tables_table.this.created_at
}

output "created_by" {
  description = "The account ID of the account that created the table."
  value       = aws_s3tables_table.this.created_by
}

output "updated_at" {
  description = "Date and time when the table was last modified."
  value       = aws_s3tables_table.this.modified_at
}

output "updated_by" {
  description = "The account ID of the account that last modified the table."
  value       = aws_s3tables_table.this.modified_by
}

output "version_token" {
  description = "The identifier for the current version of table data."
  value       = aws_s3tables_table.this.version_token
}

output "metadata_location" {
  description = "The location of table metadata."
  value       = aws_s3tables_table.this.metadata_location
}

output "warehouse_location" {
  description = "The S3 URI pointing to the S3 bucket that contains the table data."
  value       = aws_s3tables_table.this.warehouse_location
}

output "metadata" {
  description = "The metadata of the table. Only reflects the initial metadata defined when the table was created. The schema is evolved by query engines afterwards."
  value = (length(aws_s3tables_table.this.metadata) > 0
    ? {
      schema = [
        for field in aws_s3tables_table.this.metadata[0].iceberg[0].schema[0].field : {
          name     = field.name
          type     = field.type
          required = field.required
        }
      ]
      properties = aws_s3tables_table.this.metadata[0].iceberg[0].properties
    }
    : null
  )
}

output "encryption" {
  description = "The configuration for the Server-Side Encryption of the table. `override` indicates whether the table overrides the encryption configuration of the table bucket."
  value = merge(
    {
      override = var.encryption != null
    },
    (var.encryption != null
      ? {
        type = {
          for k, v in local.encryption_type :
          v => k
        }[aws_s3tables_table.this.encryption_configuration.sse_algorithm]
        kms_key = aws_s3tables_table.this.encryption_configuration.kms_key_arn
      }
      : {}
    ),
  )
}

output "maintenance" {
  description = "The maintenance configuration of the table."
  value = {
    compaction = try({
      enabled             = aws_s3tables_table.this.maintenance_configuration.iceberg_compaction.status == "enabled"
      target_file_size_mb = aws_s3tables_table.this.maintenance_configuration.iceberg_compaction.settings.target_file_size_mb
    }, null)
    snapshot_management = try({
      enabled                = aws_s3tables_table.this.maintenance_configuration.iceberg_snapshot_management.status == "enabled"
      max_snapshot_age_hours = aws_s3tables_table.this.maintenance_configuration.iceberg_snapshot_management.settings.max_snapshot_age_hours
      min_snapshots_to_keep  = aws_s3tables_table.this.maintenance_configuration.iceberg_snapshot_management.settings.min_snapshots_to_keep
    }, null)
  }
}

output "replication" {
  description = "The replication configuration of the table."
  value = merge(
    {
      enabled = local.replication_enabled
    },
    (local.replication_enabled
      ? {
        service_role = local.replication_service_role
        rules = [
          for rule in aws_s3tables_table_replication.this[0].rule : {
            destinations = rule.destination[*].destination_table_bucket_arn
          }
        ]
        version_token = aws_s3tables_table_replication.this[0].version_token
      }
      : {}
    ),
  )
}

output "resource_group" {
  description = "The resource group created to manage resources in this module."
  value = merge(
    {
      enabled = var.resource_group.enabled && var.module_tags_enabled
    },
    (var.resource_group.enabled && var.module_tags_enabled
      ? {
        arn  = module.resource_group[0].arn
        name = module.resource_group[0].name
      }
      : {}
    )
  )
}

output "debug" {
  value = {
    table = {
      for k, v in aws_s3tables_table.this :
      k => v
      if !contains(["tags", "tags_all", "region", "arn", "created_at", "encryption_configuration", "name", "namespace", "owner_account_id", "table_bucket_arn", "version_token", "format", "metadata_location", "warehouse_location", "modified_at", "type", "created_by", "modified_by", "maintenance_configuration"], k)
    }
    policy = (length(aws_s3tables_table_policy.this) > 0
      ? {
        for k, v in aws_s3tables_table_policy.this[0] :
        k => v
        if !contains(["table_bucket_arn", "resource_policy", "region", "name", "namespace"], k)
      }
      : null
    )
    replication = (local.replication_enabled
      ? {
        for k, v in aws_s3tables_table_replication.this[0] :
        k => v
        if !contains(["region", "role", "table_arn", "rule"], k)
      }
      : null
    )
  }
}
