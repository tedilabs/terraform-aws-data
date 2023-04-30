output "arn" {
  description = "The ARN of the QuickSight namespace."
  value       = aws_quicksight_namespace.this.arn
}

output "name" {
  description = "The name of the QuickSight namespace."
  value       = aws_quicksight_namespace.this.namespace
}

output "identity_store" {
  description = "The type of user identity directory."
  value       = aws_quicksight_namespace.this.identity_store
}

output "capacity_region" {
  description = "The AWS Region that you want to use for the free SPICE capacity for the new namespace."
  value       = aws_quicksight_namespace.this.capacity_region
}
