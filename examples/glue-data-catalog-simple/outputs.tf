output "data_catalog" {
  description = "The Glue Data Catalog."
  value       = module.data_catalog
}

output "database" {
  description = "The Glue Catalog Database."
  value       = module.database
}

output "table" {
  description = "The Glue Catalog Table."
  value       = module.table
}
