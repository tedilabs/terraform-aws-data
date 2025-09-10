data "aws_canonical_user_id" "this" {}

locals {
  default_grants = [
    {
      type       = "CanonicalUser"
      grantee    = data.aws_canonical_user_id.this.id
      permission = "FULL_CONTROL"
    }
  ]

  grants = concat(
    local.default_grants,
    var.grants
  )
}


###################################################
# Policy for S3 Bucket
###################################################

data "aws_iam_policy_document" "this" {
  source_policy_documents = concat(
    var.tls_required ? [data.aws_iam_policy_document.tls_required.json] : [],
    var.logging.is_target_bucket ? [data.aws_iam_policy_document.access_logging.json] : [],
  )
  override_policy_documents = var.policy != null ? [var.policy] : null
}

resource "aws_s3_bucket_policy" "this" {
  region = var.region

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this.json
}


###################################################
# Object Ownership for S3 Bucket
###################################################

resource "aws_s3_bucket_ownership_controls" "this" {
  region = var.region

  bucket = aws_s3_bucket.this.bucket

  rule {
    object_ownership = var.object_ownership
  }
}


###################################################
# ACL for S3 Bucket
###################################################

# INFO: Not supported attributes
# - `expected_bucket_owner`
# - `acl`
# - `access_control_policy.owner.display_name`
resource "aws_s3_bucket_acl" "this" {
  count = var.object_ownership != "BucketOwnerEnforced" ? 1 : 0

  region = var.region

  bucket = aws_s3_bucket.this.bucket

  access_control_policy {
    dynamic "grant" {
      for_each = local.grants

      content {
        grantee {
          type          = grant.value.type
          id            = grant.value.type == "CanonicalUser" ? grant.value.grantee : null
          uri           = grant.value.type == "Group" ? grant.value.grantee : null
          email_address = grant.value.type == "AmazonCustomerByEmail" ? grant.value.grantee : null
        }
        permission = grant.value.permission
      }
    }

    owner {
      id = data.aws_canonical_user_id.this.id
    }
  }
}


###################################################
# Public Access Block for S3 Bucket
###################################################

resource "aws_s3_bucket_public_access_block" "this" {
  region = var.region

  bucket = aws_s3_bucket.this.bucket

  # Block new public ACLs and uploading public objects
  block_public_acls = (var.block_public_access.enabled
  || var.block_public_access.block_public_acls_enabled)
  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = (var.block_public_access.enabled
  || var.block_public_access.ignore_public_acls_enabled)
  # Block new public bucket policies
  block_public_policy = (var.block_public_access.enabled
  || var.block_public_access.block_public_policy_enabled)
  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = (var.block_public_access.enabled
  || var.block_public_access.restrict_public_buckets_enabled)

  skip_destroy = true

  # To avoid OperationAborted: A conflicting conditional operation is currently in progress
  depends_on = [
    aws_s3_bucket_policy.this,
  ]
}


###################################################
# CORS (Cross-Origin Resource Sharing) for S3 Bucket
###################################################

# INFO: Not supported attributes
# - `expected_bucket_owner`
resource "aws_s3_bucket_cors_configuration" "this" {
  count = length(var.cors_rules) > 0 ? 1 : 0

  region = var.region

  bucket = aws_s3_bucket.this.bucket

  dynamic "cors_rule" {
    for_each = var.cors_rules

    content {
      id = coalesce(cors_rule.value.id, cors_rule.key)

      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age
    }
  }
}
