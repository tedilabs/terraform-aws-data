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
