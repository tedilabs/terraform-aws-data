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

# output "z" {
#   value       = {
#     for k, v in aws_glue_catalog_database.this :
#     k => v
#     if !contains(["name", "description", "catalog_id", "location_uri", "arn", "id", "tags", "tags_all"], k)
#   }
# }

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
