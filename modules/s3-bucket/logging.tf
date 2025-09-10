locals {
  logging_partition_date_sources = {
    "PARTITIONED_BY_DELIVERY_TIME" = "DeliveryTime"
    "PARTITIONED_BY_EVENT_TIME"    = "EventTime"
  }
}


###################################################
# Logging for S3 Bucket
###################################################

# INFO: Not supported attributes
# - `expected_bucket_owner`
# - `target_grant` (Using ACL is not recommended)
resource "aws_s3_bucket_logging" "this" {
  count = var.logging.enabled ? 1 : 0

  region = var.region

  bucket = aws_s3_bucket.this.bucket

  target_bucket = var.logging.s3_bucket
  target_prefix = var.logging.s3_key_prefix

  target_object_key_format {
    dynamic "partitioned_prefix" {
      for_each = contains(["SIMPLE", "PARTITIONED_BY_DELIVERY_TIME", "PARTITIONED_BY_EVENT_TIME"], var.logging.s3_key_format) ? ["go"] : []

      content {
        partition_date_source = local.logging_partition_date_sources[var.logging.s3_key_format]
      }
    }

    dynamic "simple_prefix" {
      for_each = var.logging.s3_key_format == "SIMPLE" ? ["go"] : []

      content {}
    }
  }
}
