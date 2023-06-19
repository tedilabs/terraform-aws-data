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

output "name" {
  description = "The name of the table."
  value       = aws_glue_catalog_table.this.name
}

output "description" {
  description = "The description of the table."
  value       = aws_glue_catalog_table.this.description
}

output "owner" {
  description = "The table owner."
  value       = aws_glue_catalog_table.this.owner
}

output "input_format" {
  description = "Absolute class name of the Hadoop `InputFormat` to use when reading table files."
  value       = one(aws_glue_catalog_table.this.storage_descriptor[*].input_format)
}

output "output_format" {
  description = "Absolute class name of the Hadoop `OutputFormat` to use when writing table files."
  value       = one(aws_glue_catalog_table.this.storage_descriptor[*].output_format)
}

output "columns" {
  description = "A list of the configurations for columns in the table."
  value       = one(aws_glue_catalog_table.this.storage_descriptor[*].columns)
}

output "parameters" {
  description = "The properties associated with this table, as a map of key-value pairs."
  value       = aws_glue_catalog_table.this.parameters
}

output "z" {
  description = "The properties associated with this table, as a map of key-value pairs."
  value = {
    for k, v in aws_glue_catalog_table.this :
    k => v
    if !contains(["name", "description", "catalog_id", "database_name", "arn", "id", "tags", "tags_all", "owner", "parameters", "storage_descriptor"], k)
  }
}

output "z_storage_descriptor" {
  description = "The properties associated with this table, as a map of key-value pairs."
  value = {
    for k, v in aws_glue_catalog_table.this.storage_descriptor[0] :
    k => v
    if !contains(["input_format", "output_format", "columns"], k)
  }
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
