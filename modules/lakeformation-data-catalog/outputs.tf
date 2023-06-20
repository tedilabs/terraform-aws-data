output "catalog" {
  description = "The ID of the Data Catalog."
  value       = aws_lakeformation_data_lake_settings.this.catalog_id
}

output "lf_tags" {
  description = "LF-Tags have a key and one or more values that can be associated with data catalog resources."
  value = {
    for k, v in aws_lakeformation_lf_tag.this :
    k => v.values
  }
}
