###################################################
# Logging for S3 Bucket
###################################################

# INFO: Not supported attributes
# - `expected_bucket_owner`
# - `target_grant` (Using ACL is not recommended)
resource "aws_s3_bucket_logging" "this" {
  count = var.logging.enabled ? 1 : 0

  bucket = aws_s3_bucket.this.bucket

  target_bucket = var.logging.s3_bucket
  target_prefix = var.logging.s3_key_prefix
}
