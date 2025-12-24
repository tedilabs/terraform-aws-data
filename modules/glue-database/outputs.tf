output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_glue_catalog_database.this.region
}

output "arn" {
  description = "The Amazon Resource Name (ARN) of the Glue Catalog Database."
  value       = aws_glue_catalog_database.this.arn
}

output "id" {
  description = "The ID of the database."
  value       = aws_glue_catalog_database.this.id
}

output "catalog" {
  description = "The ID of the Glue Catalog of the database."
  value       = aws_glue_catalog_database.this.catalog_id
}

output "name" {
  description = "The name of the database."
  value       = aws_glue_catalog_database.this.name
}

output "description" {
  description = "The description of the database."
  value       = aws_glue_catalog_database.this.description
}

output "location_uri" {
  description = "The description of the database."
  value       = aws_glue_catalog_database.this.location_uri
}

output "parameters" {
  description = "A set of key value pairs that specifies the Lambda function or functions to use for creating the data catalog."
  value       = aws_glue_catalog_database.this.parameters
}

output "federated_database" {
  description = <<EOF
  The configuration of federated database to reference an entity outside the AWS Glue Data Catalog.
  EOF
  value = length(aws_glue_catalog_database.this.federated_database) > 0 ? {
    id         = aws_glue_catalog_database.this.federated_database[0].identifier
    connection = aws_glue_catalog_database.this.federated_database[0].connection_name
  } : null
}

output "target_database" {
  description = <<EOF
  The configuration of a target database for resource linking.
  EOF
  value = length(aws_glue_catalog_database.this.target_database) > 0 ? {
    catalog  = aws_glue_catalog_database.this.target_database[0].catalog_id
    region   = aws_glue_catalog_database.this.target_database[0].region
    database = aws_glue_catalog_database.this.target_database[0].database_name
  } : null
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

output "sharing" {
  description = <<EOF
  The configuration for sharing of the Glue Database.
    `status` - An indication of whether the database is shared with other AWS accounts, or was shared with the current account by another AWS account. Sharing is configured through AWS Resource Access Manager (AWS RAM). Values are `NOT_SHARED`, `SHARED_BY_ME` or `SHARED_WITH_ME`.
    `shares` - The list of resource shares via RAM (Resource Access Manager).
  EOF
  value = {
    status = length(module.share) > 0 ? "SHARED_BY_ME" : "NOT_SHARED"
    shares = module.share
  }
}

# output "debug" {
#   value = {
#     for k, v in aws_glue_catalog_database.this :
#     k => v
#     if !contains(["name", "description", "catalog_id", "location_uri", "arn", "id", "tags", "tags_all", "parameters", "region"], k)
#   }
# }
