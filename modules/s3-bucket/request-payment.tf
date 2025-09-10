###################################################
# Request Payment for S3 Bucket
###################################################

# INFO: Not supported attributes
# - `expected_bucket_owner`
resource "aws_s3_bucket_request_payment_configuration" "this" {
  region = var.region

  bucket = aws_s3_bucket.this.bucket
  payer  = var.requester_payment_enabled ? "Requester" : "BucketOwner"
}
