output "region" {
  description = "The AWS region this module resources resides in."
  value       = var.region
}

output "name" {
  description = "The name of this module instance."
  value       = var.name
}

output "bucket" {
  description = "The name of the S3 bucket which the objects are stored in."
  value       = var.bucket
}

output "objects" {
  description = "The objects uploaded to the S3 bucket by the object key."
  value = {
    for key, object in aws_s3_object.this :
    key => {
      key           = object.key
      arn           = object.arn
      etag          = object.etag
      version_id    = object.version_id
      content_type  = object.content_type
      storage_class = object.storage_class
      source        = local.objects[key].source
    }
  }
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
