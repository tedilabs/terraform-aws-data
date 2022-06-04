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

output "client_config_enabled" {
  description = "Whether overriding workgroup configurations with client-side configurations is allowed."
  value       = var.client_config_enabled
}

output "cloudwatch_metrics_enabled" {
  description = "Whether Amazon CloudWatch metrics are enabled for the workgroup."
  value       = var.cloudwatch_metrics_enabled
}

output "query_on_s3_requester_pays_bucket_enabled" {
  description = "Whether members assigned to a workgroup to reference Amazon S3 Requester Pays buckets in queries are allowed."
  value       = var.cloudwatch_metrics_enabled
}

output "per_query_data_usage_limit" {
  description = "The limit in bytes for the maximum amount of data a query is allowed to scan"
  value       = var.per_query_data_usage_limit
}

output "query_result" {
  description = "The configuration for query result location and encryption."
  value = {
    s3_bucket     = try(var.query_result.s3_bucket, null)
    s3_key_prefix = local.query_result_s3_key_prefix
    s3_path       = local.query_result_s3_path

    s3_bucket_expected_owner             = try(var.query_result.s3_bucket_expected_owner, null)
    s3_bucket_owner_full_control_enabled = try(var.query_result.s3_bucket_owner_full_control_enabled, false)

    encryption_enabled = try(var.query_result.encryption_enabled, false)
    encryption_mode    = try(aws_athena_workgroup.this.configuration[0].result_configuration[0].encryption_configuration[0].encryption_option, null)
    encryption_kms_key = try(aws_athena_workgroup.this.configuration[0].result_configuration[0].encryption_configuration[0].kms_key_arn, null)
  }
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
