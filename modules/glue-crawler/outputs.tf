output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_glue_crawler.this.region
}

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

output "destination" {
  description = "The destination information of the crawler."
  value = {
    database     = aws_glue_crawler.this.database_name
    table_prefix = aws_glue_crawler.this.table_prefix
  }
}

output "custom_classifiers" {
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
  value = {
    type       = var.schedule.type
    expression = aws_glue_crawler.this.schedule
  }
}

output "recrawl_behavior" {
  description = "The behavior type of the crawler to recrawl from S3 data sources."
  value       = one(aws_glue_crawler.this.recrawl_policy[*].recrawl_behavior)
}

output "schema_change_policy" {
  description = "The configuration of the crawler's behavior when it detects a change in a table schema."
  value = {
    delete_behavior = one(aws_glue_crawler.this.schema_change_policy[*].delete_behavior)
    update_behavior = one(aws_glue_crawler.this.schema_change_policy[*].update_behavior)
  }
}

output "service_role" {
  description = "The Amazon Resource Name (ARN) of the IAM role used by the crawler to access other esources."
  value       = aws_glue_crawler.this.role
}

output "security_configuration" {
  description = "The name of Security Configuration of the crawler."
  value       = aws_glue_crawler.this.security_configuration
}

output "lake_formation_credentials" {
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

# output "debug" {
#   value = {
#     for k, v in aws_glue_crawler.this :
#     k => v
#     if !contains([
#       "tags_all", "tags", "name", "database_name", "region", "arn", "id", "table_prefix", "classifiers", "description", "recrawl_policy", "role", "schedule", "schema_change_policy", "security_configuration", "lineage_configuration"
#     ], k)
#   }
# }
