locals {
  metadata = {
    package = "terraform-aws-data"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}


###################################################
# S3 Vector Bucket
###################################################

locals {
  encryption_type = {
    "AES256"  = "AES256"
    "AWS_KMS" = "aws:kms"
  }
}

resource "aws_s3vectors_vector_bucket" "this" {
  region = var.region

  vector_bucket_name = var.name
  force_destroy      = var.force_destroy

  encryption_configuration {
    sse_type    = local.encryption_type[var.encryption.type]
    kms_key_arn = var.encryption.kms_key
  }

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# Policy for S3 Vector Bucket
###################################################

resource "aws_s3vectors_vector_bucket_policy" "this" {
  count = var.policy != null ? 1 : 0

  region = var.region

  vector_bucket_arn = aws_s3vectors_vector_bucket.this.vector_bucket_arn
  policy            = var.policy
}
