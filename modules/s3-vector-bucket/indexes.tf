###################################################
# Vector Indexes for S3 Vector Bucket
###################################################

resource "aws_s3vectors_index" "this" {
  for_each = {
    for index in var.indexes :
    index.name => index
  }

  region = var.region

  vector_bucket_name = aws_s3vectors_vector_bucket.this.vector_bucket_name
  index_name         = each.key

  data_type       = each.value.data_type
  dimension       = each.value.dimension
  distance_metric = each.value.distance_metric

  # INFO: Inherit the encryption configuration of the vector bucket if not provided
  dynamic "encryption_configuration" {
    for_each = each.value.encryption != null ? [each.value.encryption] : []
    iterator = encryption

    content {
      sse_type    = local.encryption_type[encryption.value.type]
      kms_key_arn = encryption.value.kms_key
    }
  }

  dynamic "metadata_configuration" {
    for_each = length(each.value.metadata.non_filterable_keys) > 0 ? ["go"] : []

    content {
      non_filterable_metadata_keys = each.value.metadata.non_filterable_keys
    }
  }

  tags = merge(
    {
      "Name" = "${local.metadata.name}/${each.key}"
    },
    local.module_tags,
    var.tags,
    each.value.tags,
  )
}
