output "id" {
  description = "The ID of the QuickSight group."
  value       = aws_quicksight_group.this.id
}

output "arn" {
  description = "The ARN of the QuickSight group."
  value       = aws_quicksight_group.this.arn
}

output "name" {
  description = "The name of the QuickSight group."
  value       = aws_quicksight_group.this.group_name
}

output "description" {
  description = "The description of the QuickSight group."
  value       = aws_quicksight_group.this.description
}

output "namespace" {
  description = "The namespace that the group belongs to."
  value       = aws_quicksight_group.this.namespace
}

output "members" {
  description = "A set of user names that you want to add to the group membership."
  value       = keys(aws_quicksight_group_membership.this)
}
