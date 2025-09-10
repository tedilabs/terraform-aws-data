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


###################################################
# S3 Bucket
###################################################

# TODO: replication_configuration
# TODO: website
# TODO: aws_s3_bucket_analytics_configuration
# TODO: aws_s3_bucket_intelligent_tiering_configuration
# TODO: aws_s3_bucket_inventory
# TODO: aws_s3_bucket_notification
# TODO: aws_s3_object
# TODO: aws_s3_bucket_metadata_configuration
resource "aws_s3_bucket" "this" {
  region = var.region

  bucket        = var.name
  force_destroy = var.force_destroy

  object_lock_enabled = var.object_lock.enabled && var.object_lock.token == ""

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )

  timeouts {
    create = var.timeouts.create
    read   = var.timeouts.read
    update = var.timeouts.update
    delete = var.timeouts.delete
  }

  lifecycle {
    ignore_changes = [
      lifecycle_rule,
    ]
  }
}


###################################################
# Server Side Encryption for S3 Bucket
###################################################

locals {
  encryption_type = {
    "AES256"       = "AES256"
    "AWS_KMS"      = "aws:kms"
    "AWS_KMS_DSSE" = "aws:kms::dsse"
  }
}

# INFO: Not supported attributes
# - `expected_bucket_owner`
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  region = var.region

  bucket = aws_s3_bucket.this.bucket

  rule {
    bucket_key_enabled = var.encryption.bucket_key_enabled

    apply_server_side_encryption_by_default {
      sse_algorithm     = local.encryption_type[var.encryption.type]
      kms_master_key_id = var.encryption.kms_key
    }
  }
}
