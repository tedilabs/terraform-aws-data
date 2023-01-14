###################################################
# Transfer Acceleration for S3 Bucket
###################################################

# INFO: Not supported attributes
# - `expected_bucket_owner`
resource "aws_s3_bucket_accelerate_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket
  status = var.transfer_acceleration_enabled ? "Enabled" : "Suspended"
}
