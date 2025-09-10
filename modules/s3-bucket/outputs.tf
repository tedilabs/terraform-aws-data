output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_s3_bucket.this.region
}

output "name" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.this.bucket
}

output "id" {
  description = "The ID of the bucket."
  value       = aws_s3_bucket.this.id
}

output "arn" {
  description = "The ARN of the bucket."
  value       = aws_s3_bucket.this.arn
}

output "hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region."
  value       = aws_s3_bucket.this.hosted_zone_id
}
output "domain_name" {
  description = "The bucket domain name. Will be of format `bucketname.s3.amazonaws.com`."
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "regional_domain_name" {
  description = "The bucket region-specific domain name. The bucket domain name including the region name."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "object_lock" {
  description = "The configuration for the S3 Object Lock of the bucket."
  value = {
    enabled           = var.object_lock.enabled
    default_retention = var.object_lock.default_retention
  }
}

output "versioning" {
  description = "The versioning configuration for the bucket."
  value = {
    status = {
      for k, v in local.versioning_status :
      v => k
    }[aws_s3_bucket_versioning.this.versioning_configuration[0].status]
    mfa_deletion = var.versioning.mfa_deletion
  }
}

output "lifecycle" {
  description = "The lifecycle configuration for the bucket."
  value = {
    transition_default_min_object_size_strategy = var.lifecycle_transition_default_min_object_size_strategy
    rules = {
      for rule in try(aws_s3_bucket_lifecycle_configuration.this[0].rule, []) :
      rule.id => {
        id      = rule.id
        enabled = rule.status == "Enabled"

        filter = {
          prefix          = try(local.lifecycle_rules[rule.id].prefix, null)
          tags            = try(local.lifecycle_rules[rule.id].tags, {})
          min_object_size = try(local.lifecycle_rules[rule.id].min_object_size, null)
          max_object_size = try(local.lifecycle_rules[rule.id].max_object_size, null)
        }
      }
    }
  }
}

output "encryption" {
  description = "The configuration for the S3 bucket Server-Side Encryption."
  value = {
    type               = var.encryption.type
    kms_key            = try(one(aws_s3_bucket_server_side_encryption_configuration.this.rule[*]).apply_server_side_encryption_by_default[0].kms_master_key_id, null)
    bucket_key_enabled = one(aws_s3_bucket_server_side_encryption_configuration.this.rule[*]).bucket_key_enabled
  }
}

output "access_control" {
  description = "The configuration for the S3 bucket access control."
  value = {
    object_ownership = aws_s3_bucket_ownership_controls.this.rule[0].object_ownership
    acl = {
      enabled = aws_s3_bucket_ownership_controls.this.rule[0].object_ownership != "BucketOwnerEnforced"
      grants  = local.grants
    }
    block_public_access = {
      block_public_acls_enabled       = aws_s3_bucket_public_access_block.this.block_public_acls
      ignore_public_acls_enabled      = aws_s3_bucket_public_access_block.this.ignore_public_acls
      block_public_policy_enabled     = aws_s3_bucket_public_access_block.this.block_public_policy
      restrict_public_buckets_enabled = aws_s3_bucket_public_access_block.this.restrict_public_buckets
    }
    cors_rules = {
      for rule in try(one(aws_s3_bucket_cors_configuration.this[*]).cors_rule, []) :
      rule.id => {
        allowed_headers = rule.allowed_headers
        allowed_methods = rule.allowed_methods
        allowed_origins = rule.allowed_origins
        expose_headers  = rule.expose_headers
        max_age         = rule.max_age_seconds
      }
    }
  }
}

output "logging" {
  description = "The logging configuration for the bucket."
  value = {
    enabled       = var.logging.enabled
    s3_bucket     = one(aws_s3_bucket_logging.this[*].target_bucket)
    s3_key_prefix = one(aws_s3_bucket_logging.this[*].target_prefix)
    s3_key_format = var.logging.s3_key_format

    is_target_bucket       = var.logging.is_target_bucket
    allowed_source_buckets = var.logging.allowed_source_buckets
  }
}

output "monitoring" {
  description = "The monitoring configuration for the bucket."
  value = {
    request_metrics = [
      for name, metric in aws_s3_bucket_metric.this : {
        name   = name
        filter = one(metric.filter[*])
      }
    ]
  }
}

output "requester_payment" {
  description = "The configuration for the S3 bucket request payment."
  value = {
    enabled = aws_s3_bucket_request_payment_configuration.this.payer == "Requester"
  }
}

output "transfer_acceleration" {
  description = "The configuration for the S3 Transfer Acceleration of the bucket."
  value = {
    enabled = var.transfer_acceleration_enabled
    endpoints = {
      ipv4      = "${aws_s3_bucket.this.bucket}.s3-accelerate.amazonaws.com"
      dualstack = "${aws_s3_bucket.this.bucket}.s3-accelerate.dualstack.amazonaws.com"
    }
  }
}

output "resource_group" {
  description = "The resource group created to manage resources in this module."
  value = merge(
    {
      enabled = var.resource_group.enabled && var.module_tags_enabled
    },
    (var.resource_group.enabled && var.module_tags_enabled
      ? {
        arn  = module.resource_group[0].arn
        name = module.resource_group[0].name
      }
      : {}
    )
  )
}
