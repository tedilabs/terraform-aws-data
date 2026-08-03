###################################################
# Objects for S3 Bucket
###################################################

module "objects" {
  source = "../s3-objects"

  count = (length(var.objects.files) + length(var.objects.directories)) > 0 ? 1 : 0

  region = var.region

  name   = aws_s3_bucket.this.bucket
  bucket = aws_s3_bucket.this.bucket

  force_destroy = var.objects.force_destroy

  files       = var.objects.files
  directories = var.objects.directories

  checksum    = var.objects.checksum
  encryption  = var.objects.encryption
  object_lock = var.objects.object_lock
  metadata    = var.objects.metadata

  provider_default_tags_enabled = var.objects.provider_default_tags_enabled

  resource_group = {
    enabled = false
  }
  module_tags_enabled = false

  tags = merge(
    local.module_tags,
    var.tags,
  )
}
