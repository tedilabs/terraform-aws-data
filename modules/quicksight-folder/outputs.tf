output "id" {
  description = "The ID of the QuickSight folder."
  value       = aws_quicksight_folder.this.folder_id
}

output "arn" {
  description = "The ARN of the QuickSight folder."
  value       = aws_quicksight_folder.this.arn
}

output "name" {
  description = "The name of the QuickSight folder."
  value       = aws_quicksight_folder.this.folder_id
}

output "display_name" {
  description = "The display name of the QuickSight folder."
  value       = aws_quicksight_folder.this.name
}

output "type" {
  description = "The type of the QuickSight folder."
  value       = aws_quicksight_folder.this.folder_type
}

output "hierarchy" {
  description = "The hierarchy of the QuickSight folder."
  value = {
    path          = aws_quicksight_folder.this.folder_path
    parent_folder = aws_quicksight_folder.this.parent_folder_arn
  }
}

output "permissions" {
  description = "A list of resource permissions on the QuickSight folder."
  value       = aws_quicksight_folder.this.permissions
}

output "created_at" {
  description = "The time that the QuickSight folder was created."
  value       = aws_quicksight_folder.this.created_time
}

output "updated_at" {
  description = "The time that the QuickSight folder was last updated."
  value       = aws_quicksight_folder.this.last_updated_time
}
