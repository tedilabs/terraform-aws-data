output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_s3tables_table_bucket.this.region
}

output "name" {
  description = "The name of the table bucket."
  value       = aws_s3tables_table_bucket.this.name
}

output "arn" {
  description = "The ARN of the table bucket."
  value       = aws_s3tables_table_bucket.this.arn
}

output "owner" {
  description = "The account ID of the account that owns the table bucket."
  value       = aws_s3tables_table_bucket.this.owner_account_id
}

output "created_at" {
  description = "Date and time when the table bucket was created."
  value       = aws_s3tables_table_bucket.this.created_at
}

output "encryption" {
  description = "The configuration for the Server-Side Encryption of the table bucket."
  value = {
    type = {
      for k, v in local.encryption_type :
      v => k
    }[aws_s3tables_table_bucket.this.encryption_configuration.sse_algorithm]
    kms_key = aws_s3tables_table_bucket.this.encryption_configuration.kms_key_arn
  }
}

output "maintenance" {
  description = "The maintenance configuration of the table bucket."
  value = {
    unreferenced_file_removal = try({
      enabled           = aws_s3tables_table_bucket.this.maintenance_configuration.iceberg_unreferenced_file_removal.status == "enabled"
      unreferenced_days = aws_s3tables_table_bucket.this.maintenance_configuration.iceberg_unreferenced_file_removal.settings.unreferenced_days
      non_current_days  = aws_s3tables_table_bucket.this.maintenance_configuration.iceberg_unreferenced_file_removal.settings.non_current_days
    }, null)
  }
}

output "namespaces" {
  description = "The namespaces created in the table bucket."
  value = {
    for name, namespace in aws_s3tables_namespace.this :
    name => {
      name       = namespace.namespace
      created_at = namespace.created_at
      created_by = namespace.created_by
      owner      = namespace.owner_account_id
    }
  }
}

output "replication" {
  description = "The replication configuration of the table bucket."
  value = merge(
    {
      enabled = local.replication_enabled
    },
    (local.replication_enabled
      ? {
        service_role = local.replication_service_role
        rules = [
          for rule in aws_s3tables_table_bucket_replication.this[0].rule : {
            destinations = rule.destination[*].destination_table_bucket_arn
          }
        ]
        version_token = aws_s3tables_table_bucket_replication.this[0].version_token
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

# output "debug" {
#   value = {
#     bucket = {
#       for k, v in aws_s3tables_table_bucket.this :
#       k => v
#       if !contains(["tags", "tags_all", "region", "arn", "created_at", "force_destroy", "name", "owner_account_id", "encryption_configuration", "maintenance_configuration"], k)
#     }
#     policy = (length(aws_s3tables_table_bucket_policy.this) > 0
#       ? {
#         for k, v in aws_s3tables_table_bucket_policy.this[0] :
#         k => v
#         if !contains(["table_bucket_arn", "resource_policy", "region"], k)
#       }
#       : null
#     )
#     namespaces = {
#       for name, namespace in aws_s3tables_namespace.this :
#       name => {
#         for k, v in namespace :
#         k => v
#         if !contains(["region", "table_bucket_arn", "created_at", "created_by", "owner_account_id", "namespace"], k)
#       }
#     }
#   }
# }
