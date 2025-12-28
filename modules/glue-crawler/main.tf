locals {
  metadata = {
    package = "terraform-aws-data"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}

locals {
  data_sources_count = length(concat(
    var.catalog_data_sources,
    var.delta_lake_data_sources,
    var.dynamodb_data_sources,
    var.jdbc_data_sources,
    var.mongodb_data_sources,
    var.s3_data_sources,
  ))
}


###################################################
# Glue Crawler
###################################################

resource "aws_glue_crawler" "this" {
  region = var.region

  name        = var.name
  description = var.description

  configuration = var.configuration

  lineage_configuration {
    crawler_lineage_settings = var.data_lineage_enabled ? "ENABLE" : "DISABLE"
  }

  ## Destination
  database_name = var.destination.database
  table_prefix  = var.destination.table_prefix


  ## Data Sources
  classifiers = var.custom_classifiers

  dynamic "catalog_target" {
    for_each = var.catalog_data_sources
    iterator = source

    content {
      database_name   = source.value.database
      tables          = source.value.tables
      connection_name = source.value.connection

      event_queue_arn     = var.recrawl_behavior == "CRAWL_EVENT_MODE" ? source.value.event_mode.sqs_queue : null
      dlq_event_queue_arn = var.recrawl_behavior == "CRAWL_EVENT_MODE" ? source.value.event_mode.sqs_dead_letter_queue : null
    }
  }

  dynamic "delta_target" {
    for_each = var.delta_lake_data_sources
    iterator = source

    content {
      delta_tables    = source.value.paths
      connection_name = source.value.connection

      create_native_delta_table = source.value.table_type == "NATIVE_TABLES"
      write_manifest            = source.value.write_manifest
    }
  }

  dynamic "dynamodb_target" {
    for_each = var.dynamodb_data_sources
    iterator = source

    content {
      path = source.value.path

      scan_rate = source.value.scanning_rate
      scan_all  = source.value.data_sampling_enabled
    }
  }

  dynamic "jdbc_target" {
    for_each = var.jdbc_data_sources
    iterator = source

    content {
      path            = source.value.path
      connection_name = source.value.connection

      exclusions                 = source.value.exclusion_patterns
      enable_additional_metadata = source.value.additional_metadata_properties
    }
  }

  dynamic "mongodb_target" {
    for_each = var.mongodb_data_sources
    iterator = source

    content {
      path            = source.value.path
      connection_name = source.value.connection

      scan_all = source.value.data_sampling_enabled
    }
  }

  dynamic "s3_target" {
    for_each = var.s3_data_sources
    iterator = source

    content {
      path            = source.value.path
      connection_name = source.value.connection

      exclusions  = source.value.exclusion_patterns
      sample_size = source.value.sample_size

      event_queue_arn     = var.recrawl_behavior == "CRAWL_EVENT_MODE" ? source.value.event_mode.sqs_queue : null
      dlq_event_queue_arn = var.recrawl_behavior == "CRAWL_EVENT_MODE" ? source.value.event_mode.sqs_dead_letter_queue : null
    }
  }


  ## Scheduling
  schedule = (var.schedule.type == "CRON_EXPRESSION"
    ? var.schedule.expression
    : null
  )

  recrawl_policy {
    recrawl_behavior = var.recrawl_behavior
  }

  schema_change_policy {
    delete_behavior = var.schema_change_policy.delete_behavior
    update_behavior = var.schema_change_policy.update_behavior
  }


  ## Security
  role = (var.default_service_role.enabled
    ? module.role[0].arn
    : var.service_role
  )

  security_configuration = var.security_configuration

  lake_formation_configuration {
    use_lake_formation_credentials = var.lake_formation_credentials.enabled
    account_id                     = var.lake_formation_credentials.account_id
  }


  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )

  lifecycle {
    precondition {
      condition = anytrue([
        length(var.catalog_data_sources) == 0,
        length(var.catalog_data_sources) == local.data_sources_count,
      ])
      error_message = "The crawler cannot have Glue Data Catalog data sources mixed with other data source types. Specify crawler data sources that include only Glue Data Catalog, or only other data sources."
    }
    precondition {
      condition = anytrue([
        length(var.delta_lake_data_sources) == 0,
        length(var.delta_lake_data_sources) == local.data_sources_count,
      ])
      error_message = "The crawler cannot have Delta Lake data sources mixed with other data source types. Specify crawler data sources that include only Delta Lake, or only other data sources."
    }
  }
}
