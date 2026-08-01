locals {
  metadata = {
    package = "terraform-aws-data"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}

locals {
  directory_files = flatten([
    for directory in var.directories : [
      for file in setsubtract(
        toset(flatten([
          for pattern in directory.include_patterns :
          fileset(directory.path, pattern)
        ])),
        toset(flatten([
          for pattern in directory.exclude_patterns :
          fileset(directory.path, pattern)
        ])),
        ) : {
        key = "${directory.key_prefix}${file}"

        source       = "${directory.path}/${file}"
        content      = null
        content_type = null

        storage_class       = directory.storage_class
        cache_control       = directory.cache_control
        content_disposition = null
        content_encoding    = null
        content_language    = null
        website_redirect    = null
        metadata            = directory.metadata

        force_destroy = directory.force_destroy
        tags          = directory.tags
      }
    ]
  ])
  objects = merge(
    {
      for object in local.directory_files :
      object.key => object
    },
    {
      for object in var.files :
      object.key => object
    },
  )
}


###################################################
# Objects for S3 Bucket
###################################################

locals {
  mime_types = {
    "css"   = "text/css"
    "csv"   = "text/csv"
    "eot"   = "application/vnd.ms-fontobject"
    "gif"   = "image/gif"
    "gz"    = "application/gzip"
    "htm"   = "text/html"
    "html"  = "text/html"
    "ico"   = "image/vnd.microsoft.icon"
    "jpeg"  = "image/jpeg"
    "jpg"   = "image/jpeg"
    "js"    = "text/javascript"
    "json"  = "application/json"
    "map"   = "application/json"
    "md"    = "text/markdown"
    "mjs"   = "text/javascript"
    "mp3"   = "audio/mpeg"
    "mp4"   = "video/mp4"
    "otf"   = "font/otf"
    "pdf"   = "application/pdf"
    "png"   = "image/png"
    "svg"   = "image/svg+xml"
    "tar"   = "application/x-tar"
    "ttf"   = "font/ttf"
    "txt"   = "text/plain"
    "wasm"  = "application/wasm"
    "webm"  = "video/webm"
    "webp"  = "image/webp"
    "woff"  = "font/woff"
    "woff2" = "font/woff2"
    "xml"   = "application/xml"
    "yaml"  = "application/yaml"
    "yml"   = "application/yaml"
    "zip"   = "application/zip"
  }
}

# INFO: Not supported attributes
# - `acl`
# - `checksum_algorithm`
# - `content_base64`
# - `etag`
# - `expected_bucket_owner`
# - `kms_key_id`
# - `object_lock_legal_hold_status`
# - `object_lock_mode`
# - `object_lock_retain_until_date`
# - `server_side_encryption`
resource "aws_s3_object" "this" {
  for_each = local.objects

  region = var.region

  bucket = var.bucket
  key    = each.key

  source      = each.value.source
  content     = each.value.content
  source_hash = each.value.source != null ? filemd5(each.value.source) : null

  content_type = coalesce(
    each.value.content_type,
    try(local.mime_types[lower(regex("\\.([[:alnum:]]+)$", each.value.key)[0])], "application/octet-stream"),
  )

  storage_class       = each.value.storage_class
  cache_control       = each.value.cache_control
  content_disposition = each.value.content_disposition
  content_encoding    = each.value.content_encoding
  content_language    = each.value.content_language
  website_redirect    = each.value.website_redirect
  metadata            = each.value.metadata

  force_destroy = each.value.force_destroy

  tags = merge(
    {
      "Name" = "${var.bucket}/${each.key}"
    },
    local.module_tags,
    var.tags,
    each.value.tags,
  )
}
