###################################################
# S3 Access Point
###################################################

# INFO: Not supported attributes
# - `account_id`
resource "aws_s3_access_point" "this" {
  name = var.name

  bucket            = var.bucket.name
  bucket_account_id = var.bucket.account_id

  dynamic "vpc_configuration" {
    for_each = var.network_origin == "VPC" ? [var.vpc_id] : []

    content {
      vpc_id = vpc_configuration.value
    }
  }

  public_access_block_configuration {
    block_public_acls = (var.block_public_access.enabled
    || var.block_public_access.block_public_acls_enabled)
    ignore_public_acls = (var.block_public_access.enabled
    || var.block_public_access.ignore_public_acls_enabled)
    block_public_policy = (var.block_public_access.enabled
    || var.block_public_access.block_public_policy_enabled)
    restrict_public_buckets = (var.block_public_access.enabled
    || var.block_public_access.restrict_public_buckets_enabled)
  }

  lifecycle {
    precondition {
      condition = anytrue([
        var.network_origin != "VPC",
        var.network_origin == "VPC" && var.vpc_id != null,
      ])
      error_message = "`vpc_id` is required when the value of `network_origin` is `VPC`."
    }

    ignore_changes = [
      policy,
    ]
  }
}


###################################################
# Policy for S3 Access Point
###################################################

resource "aws_s3control_access_point_policy" "this" {
  count = var.policy != "" ? 1 : 0

  access_point_arn = aws_s3_access_point.this.arn
  policy           = var.policy
}
