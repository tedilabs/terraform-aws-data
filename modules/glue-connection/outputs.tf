output "arn" {
  description = "The Amazon Resource Name (ARN) of the Glue connection."
  value       = aws_glue_connection.this.arn
}

output "id" {
  description = "The ID of the Glue connection."
  value       = aws_glue_connection.this.id
}

output "catalog" {
  description = "The ID of the Glue Catalog."
  value       = aws_glue_connection.this.catalog_id
}

output "name" {
  description = "The name of the Glue connection."
  value       = aws_glue_connection.this.name
}

output "description" {
  description = "The description of the Glue connection."
  value       = aws_glue_connection.this.description
}

output "type" {
  description = "The type of the connection."
  value       = aws_glue_connection.this.connection_type
}

output "properties" {
  description = "A map of key-value pairs used as parameters for this connection."
  value       = aws_glue_connection.this.connection_properties
  sensitive   = true
}

output "vpc_association" {
  description = "A configuration for additional VPC association of the Glue connection when your AWS Glue job needs to run on Amazon Elastic Compute Cloud (EC2) instances in a virtual private cloud (VPC) subnet."
  value = (var.vpc_association.enabled
    ? {
      vpc               = one(data.aws_subnet.this[*].vpc_id)
      availability_zone = aws_glue_connection.this.physical_connection_requirements[0].availability_zone
      subnet            = aws_glue_connection.this.physical_connection_requirements[0].subnet_id

      security_groups = aws_glue_connection.this.physical_connection_requirements[0].security_group_id_list
    } : null
  )
}

output "match_criteria" {
  description = "A list of criteria that can be used in selecting this connection."
  value       = aws_glue_connection.this.match_criteria
}
