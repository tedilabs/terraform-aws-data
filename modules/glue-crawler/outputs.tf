output "arn" {
  description = "The Amazon Resource Name (ARN) of the Glue crawler."
  value       = aws_glue_crawler.this.arn
}

output "id" {
  description = "The ID of the Glue crawler."
  value       = aws_glue_crawler.this.id
}

output "name" {
  description = "The name of the Glue crawler."
  value       = aws_glue_crawler.this.name
}

output "description" {
  description = "The description of the Glue crawler."
  value       = aws_glue_crawler.this.description
}

output "configuration" {
  description = "The configuration information of the crawler as JSON string."
  value       = aws_glue_crawler.this.configuration
}

output "data_lineage_enabled" {
  description = "Whether data lineage is enabled for the crawler."
  value       = aws_glue_crawler.this.lineage_configuration[0].crawler_lineage_settings == "ENABLE"
}

output "database" {
  description = "The Glue database where results are written."
  value       = aws_glue_crawler.this.database_name
}

output "table_prefix" {
  description = "The table prefix used for catalog tables that are created."
  value       = aws_glue_crawler.this.table_prefix
}

output "classifiers" {
  description = "A list of custom classifiers to use with this crawler."
  value       = aws_glue_crawler.this.classifiers
}

output "data_sources" {
  description = <<EOF
  The configuration for data sources of the the crawler.
    `catalog` - A list of Glue Data Catalog data sources to be scanned by the crawler.
    `delta_lake` - A list of Delta Lake data sources to be scanned by the crawler.
    `dynamodb` - A list of DynamoDB data sources to be scanned by the crawler.
    `jdbc` - A list of JDBC data sources to be scanned by the crawler.
    `mongodb` - A list of MongoDB data sources to be scanned by the crawler.
    `s3` - A list of S3 data sources to be scanned by the crawler.
  EOF
  value = {
    catalog = [
      for source in aws_glue_crawler.this.catalog_target : {
        database   = source.database_name
        tables     = source.tables
        connection = source.connection_name

        event_mode = {
          sqs_queue             = source.event_queue_arn
          sqs_dead_letter_queue = source.dlq_event_queue_arn
        }
      }
    ]
    delta_lake = [
      for source in aws_glue_crawler.this.delta_target : {
        paths      = source.delta_tables
        connection = source.connection_name

        table_type     = source.create_native_delta_table ? "NATIVE_TABLES" : "SYMLINK_TABLES"
        write_manifest = source.write_manifest
      }
    ]
    dynamodb = [
      for source in aws_glue_crawler.this.dynamodb_target : {
        path = source.path

        scanning_rate         = source.scan_rate
        data_sampling_enabled = source.scan_all
      }
    ]
    jdbc = [
      for source in aws_glue_crawler.this.jdbc_target : {
        path       = source.path
        connection = source.connection_name

        exclusion_patterns             = source.exclusions
        additional_metadata_properties = source.enable_additional_metadata
      }
    ]
    mongodb = [
      for source in aws_glue_crawler.this.mongodb_target : {
        path       = source.path
        connection = source.connection_name

        data_sampling_enabled = source.scan_all
      }
    ]
    s3 = [
      for source in aws_glue_crawler.this.s3_target : {
        path       = source.path
        connection = source.connection_name

        exclusion_patterns = source.exclusions
        sample_size        = source.sample_size

        event_mode = {
          sqs_queue             = source.event_queue_arn
          sqs_dead_letter_queue = source.dlq_event_queue_arn
        }
      }
    ]
  }
}

output "schedule" {
  description = "The cron expression used to specify the schedule."
  value       = aws_glue_crawler.this.schedule
}

output "on_recrawl_behavior" {
  description = "The behavior type of the crawler to recrawl from S3 data sources."
  value       = one(aws_glue_crawler.this.recrawl_policy[*].recrawl_behavior)
}

output "on_object_deletion_behavior" {
  description = "The behavior type when the crawler finds a deleted object."
  value       = one(aws_glue_crawler.this.schema_change_policy[*].delete_behavior)
}

output "on_schema_change_behavior" {
  description = "The behavior type when the crawler finds a changed schema."
  value       = one(aws_glue_crawler.this.schema_change_policy[*].update_behavior)
}

output "iam_role" {
  description = "The IAM role used by the crawler to access other resources."
  value = {
    arn = coalesce(
      one(data.aws_iam_role.custom[*].arn),
      one(module.role[*].arn),
    )
    name = coalesce(
      one(data.aws_iam_role.custom[*].name),
      one(module.role[*].name),
    )
    description = coalesce(
      one(data.aws_iam_role.custom[*].description),
      one(module.role[*].description),
    )
  }
}

output "security_configuration" {
  description = "The name of Security Configuration of the crawler."
  value       = aws_glue_crawler.this.security_configuration
}

output "lake_formation_credentials_configuration" {
  description = "The configuration of the crawler to use Lake Formation credentials for crawling the data source."
  value = {
    enabled    = one(aws_glue_crawler.this.lake_formation_configuration[*].use_lake_formation_credentials)
    account_id = one(aws_glue_crawler.this.lake_formation_configuration[*].account_id)
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
