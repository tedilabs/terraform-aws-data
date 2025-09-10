output "arn" {
  description = "The Amazon Resource Name (ARN) of the data catalog."
  value       = aws_athena_data_catalog.this.arn
}

output "id" {
  description = "The ID of the data catalog."
  value       = aws_athena_data_catalog.this.id
}

output "name" {
  description = "The name of the data catalog."
  value       = aws_athena_data_catalog.this.name
}

output "description" {
  description = "The description of the data catalog."
  value       = aws_athena_data_catalog.this.description
}

output "type" {
  description = "The type of the data catalog."
  value       = aws_athena_data_catalog.this.type
}

output "parameters" {
  description = "A set of key value pairs that specifies the Lambda function or functions to use for creating the data catalog."
  value       = aws_athena_data_catalog.this.parameters
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
