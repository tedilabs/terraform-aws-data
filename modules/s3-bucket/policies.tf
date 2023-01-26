data "aws_caller_identity" "this" {}

locals {
  account_id = data.aws_caller_identity.this.account_id
}

## Enforce TLS (HTTPS Only)
data "aws_iam_policy_document" "tls_required" {
  statement {
    sid = "RequireTlsForRequest"

    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.name}",
      "arn:aws:s3:::${var.name}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

data "aws_iam_policy_document" "access_logging" {
  statement {
    sid = "S3ServerAccessLogsPolicy"

    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "arn:aws:s3:::${var.name}/*",
    ]

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    dynamic "condition" {
      for_each = length(var.logging.allowed_source_buckets) > 0 ? ["go"] : []

      content {
        test     = "StringLike"
        variable = "aws:SourceArn"
        values = [
          for bucket in var.logging.allowed_source_buckets :
          "arn:aws:s3:::${bucket}"
        ]
      }
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
  }
}
