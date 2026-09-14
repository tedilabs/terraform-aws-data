output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_glue_catalog_table.this.region
}

output "arn" {
  description = "The Amazon Resource Name (ARN) of the Glue Catalog Table."
  value       = aws_glue_catalog_table.this.arn
}

output "id" {
  description = "The ID of the database."
  value       = aws_glue_catalog_table.this.id
}

output "catalog" {
  description = "The ID of the Glue Catalog of the table."
  value       = aws_glue_catalog_table.this.catalog_id
}

output "database" {
  description = "The catalog database in which to create the new table."
  value       = aws_glue_catalog_table.this.database_name
}

output "owner" {
  description = "The table owner."
  value       = aws_glue_catalog_table.this.owner
}

output "name" {
  description = "The name of the table."
  value       = aws_glue_catalog_table.this.name
}

output "description" {
  description = "The description of the table."
  value       = aws_glue_catalog_table.this.description
}

output "type" {
  description = "The type of the table."
  value       = aws_glue_catalog_table.this.table_type
}

output "location" {
  description = "The physical location of the table."
  value       = one(aws_glue_catalog_table.this.storage_descriptor[*].location)
}

output "input_format" {
  description = "Absolute class name of the Hadoop `InputFormat` to use when reading table files."
  value       = one(aws_glue_catalog_table.this.storage_descriptor[*].input_format)
}

output "output_format" {
  description = "Absolute class name of the Hadoop `OutputFormat` to use when writing table files."
  value       = one(aws_glue_catalog_table.this.storage_descriptor[*].output_format)
}

output "compressed" {
  description = "Whether the data in the table is compressed."
  value       = one(aws_glue_catalog_table.this.storage_descriptor[*].compressed)
}

output "columns" {
  description = "A list of the configurations for columns in the table."
  value       = one(aws_glue_catalog_table.this.storage_descriptor[*].columns)
}

output "ser_de" {
  description = "The configuration of the SerDe (Serializer/Deserializer) of the table."
  value       = one(aws_glue_catalog_table.this.storage_descriptor[0].ser_de_info[*])
}

output "partition_keys" {
  description = "A list of columns by which the table is partitioned."
  value       = aws_glue_catalog_table.this.partition_keys
}

output "parameters" {
  description = "The properties associated with this table, as a map of key-value pairs."
  value       = aws_glue_catalog_table.this.parameters
}

output "sharing" {
  description = <<EOF
  The configuration for sharing of the Glue Table.
    `status` - An indication of whether the table is shared with other AWS accounts, or was shared with the current account by another AWS account. Sharing is configured through AWS Resource Access Manager (AWS RAM). Values are `NOT_SHARED`, `SHARED_BY_ME` or `SHARED_WITH_ME`.
    `shares` - The list of resource shares via RAM (Resource Access Manager).
  EOF
  value = {
    status = length(module.share) > 0 ? "SHARED_BY_ME" : "NOT_SHARED"
    shares = module.share
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
