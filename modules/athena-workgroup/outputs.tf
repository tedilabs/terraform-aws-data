output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_athena_workgroup.this.region
}

output "arn" {
  description = "The Amazon Resource Name (ARN) of the workgroup."
  value       = aws_athena_workgroup.this.arn
}

output "id" {
  description = "The workgroup name."
  value       = aws_athena_workgroup.this.id
}

output "name" {
  description = "The name of the workgroup."
  value       = aws_athena_workgroup.this.name
}

output "description" {
  description = "The description of the workgroup."
  value       = aws_athena_workgroup.this.description
}

output "enabled" {
  description = "Whether to enable the workgroup."
  value       = var.enabled
}

output "force_destroy" {
  description = "Whether to delete the workgroup and its contents even if the workgroup contains any named queries."
  value       = var.force_destroy
}

output "analytics_engine" {
  description = "The configuration for the Athena engine version."
  value = {
    version           = var.analytics_engine.version
    effective_version = aws_athena_workgroup.this.configuration[0].engine_version[0].effective_engine_version
  }
}

output "query_result" {
  description = "The configuration for query result location and encryption."
  value = (local.engine_type == "ATHENA_SQL"
    ? {
      management_mode        = aws_athena_workgroup.this.configuration[0].managed_query_results_configuration[0].enabled ? "ATHENA_MANAGED" : "CUSTOMER_MANAGED"
      override_client_config = aws_athena_workgroup.this.configuration[0].enforce_workgroup_configuration

      athena_managed_query_result = (aws_athena_workgroup.this.configuration[0].managed_query_results_configuration[0].enabled
        ? {
          encryption = {
            kms_key = aws_athena_workgroup.this.configuration[0].managed_query_results_configuration[0].encryption_configuration[0].kms_key
          }
        }
        : null
      )
      customer_managed_query_result = (!aws_athena_workgroup.this.configuration[0].managed_query_results_configuration[0].enabled
        ? {
          s3_bucket = {
            uri                               = aws_athena_workgroup.this.configuration[0].result_configuration[0].output_location
            name                              = var.query_result.customer_managed_query_result.s3_bucket.name
            key_prefix                        = var.query_result.customer_managed_query_result.s3_bucket.key_prefix
            expected_bucket_owner             = aws_athena_workgroup.this.configuration[0].result_configuration[0].expected_bucket_owner
            bucket_owner_full_control_enabled = one(aws_athena_workgroup.this.configuration[0].result_configuration[0].acl_configuration) != null
          }
          encryption = {
            enabled = one(aws_athena_workgroup.this.configuration[0].result_configuration[0].encryption_configuration) != null
            mode    = one(aws_athena_workgroup.this.configuration[0].result_configuration[0].encryption_configuration[*].encryption_option)
            kms_key = one(aws_athena_workgroup.this.configuration[0].result_configuration[0].encryption_configuration[*].kms_key_arn)
          }
        }
        : null
      )
    }
    : null
  )
}

output "iam_identity_center" {
  description = "The configuration for query result location and encryption."
  value = (local.engine_type == "ATHENA_SQL"
    ? {
      enabled  = aws_athena_workgroup.this.configuration[0].identity_center_configuration[0].enable_identity_center
      instance = aws_athena_workgroup.this.configuration[0].identity_center_configuration[0].identity_center_instance_arn
    }
    : null
  )
}

output "cloudwatch_metrics_enabled" {
  description = "Whether Amazon CloudWatch metrics are enabled for the workgroup."
  value       = var.cloudwatch_metrics_enabled
}

output "query_on_s3_requester_pays_bucket_enabled" {
  description = "Whether members assigned to a workgroup to reference Amazon S3 Requester Pays buckets in queries are allowed."
  value       = var.query_on_s3_requester_pays_bucket_enabled
}

output "per_query_data_usage_limit" {
  description = "The limit in bytes for the maximum amount of data a query is allowed to scan"
  value       = var.per_query_data_usage_limit
}

output "named_queries" {
  description = "The list of Athena named queries."
  value = {
    for name, query in aws_athena_named_query.this :
    name => {
      id          = query.id
      name        = query.name
      description = query.description
      database    = query.database
    }
  }
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
