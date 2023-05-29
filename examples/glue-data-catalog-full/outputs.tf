output "kms_key" {
  description = "The KMS Key for encryption of Glue Data Catalog."
  value       = module.kms_key
}

output "data_catalog" {
  description = "The Glue Data Catalog."
  value       = module.data_catalog
}
