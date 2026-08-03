output "region" {
  description = "The AWS region this module resources resides in."
  value       = data.aws_region.this.region
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
      id            = object.id
      key           = object.key
      arn           = object.arn
      etag          = object.etag
      version_id    = object.version_id
      content_type  = object.content_type
      storage_class = object.storage_class
      source        = local.objects[key].source
      website_redirect = (object.website_redirect != ""
        ? object.website_redirect
        : null
      )
      checksum = {
        enabled   = var.checksum.enabled
        algorithm = var.checksum.algorithm
        value = (var.checksum.enabled
          ? {
            "CRC32"     = object.checksum_crc32
            "CRC32C"    = object.checksum_crc32c
            "CRC64NVME" = object.checksum_crc64nvme
            "SHA1"      = object.checksum_sha1
            "SHA256"    = object.checksum_sha256
          }[var.checksum.algorithm]
          : null
        )
      }
      encryption = {
        type = try(
          {
            for k, v in local.encryption_type :
            v => k
          }[object.server_side_encryption],
          object.server_side_encryption,
        )
        kms_key            = object.kms_key_id
        bucket_key_enabled = object.bucket_key_enabled
      }
      object_lock = {
        legal_hold_enabled = (object.object_lock_legal_hold_status != ""
          ? object.object_lock_legal_hold_status == "ON"
          : null
        )
        retention = (object.object_lock_mode != ""
          ? {
            mode              = object.object_lock_mode
            retain_until_date = object.object_lock_retain_until_date
          }
          : null
        )
      }
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

# output "debug" {
#   value = {
#     for key, object in aws_s3_object.this :
#     key => {
#       for k, v in object :
#       k => v
#       if !contains(["key", "arn", "etag", "version_id", "content_type", "storage_class", "bucket", "id", "tags", "tags_all", "region", "override_provider", "force_destroy", "content", "content_base64", "checksum_algorithm", "checksum_sha1", "checksum_sha256", "checksum_crc32", "checksum_crc32c", "checksum_crc64nvme", "bucket_key_enabled", "kms_key_id", "server_side_encryption", "object_lock_mode", "object_lock_retain_until_date", "object_lock_legal_hold_status", "metadata", "source", "source_hash", "acl", "cache_control", "content_disposition", "content_encoding", "content_language", "website_redirect", "acl"], k)
#     }
#   }
# }
