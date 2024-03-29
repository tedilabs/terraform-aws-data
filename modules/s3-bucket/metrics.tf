###################################################
# Request Metrics for S3 Bucket
###################################################

# TODO: Support access point filter
resource "aws_s3_bucket_metric" "this" {
  for_each = {
    for metric in var.request_metrics :
    metric.name => metric
  }

  bucket = aws_s3_bucket.this.bucket
  name   = each.key

  dynamic "filter" {
    for_each = each.value.filter != null ? [each.value.filter] : []

    content {
      prefix = filter.value.prefix
      tags   = filter.value.tags
    }
  }
}
