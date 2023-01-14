###################################################
# Logging for S3 Bucket
###################################################

# INFO: Not supported attributes
# - `expected_bucket_owner`
# TODO: `target_grant`
resource "aws_s3_bucket_logging" "this" {
  count = var.logging_enabled ? 1 : 0

  bucket = aws_s3_bucket.this.bucket

  target_bucket = var.logging_s3_bucket
  target_prefix = try(var.logging_s3_key_prefix, null)
}
