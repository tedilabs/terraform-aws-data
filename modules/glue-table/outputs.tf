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

# output "z" {
#   value       = {
#     for k, v in aws_glue_catalog_table.this :
#     k => v
#     if !contains(["name", "description", "catalog_id", "database_name", "arn", "id", "tags", "tags_all"], k)
#   }
# }

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
