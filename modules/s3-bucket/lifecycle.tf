locals {
  versioning_status = {
    "ENABLED"   = "Enabled"
    "DISABLED"  = "Disabled"
    "SUSPENDED" = "Suspended"
  }

  lifecycle_rules = {
    for rule in var.lifecycle_rules :
    rule.id => rule
  }
}


###################################################
# Versioning for S3 Bucket
###################################################

# INFO: Not supported attributes
# - `expected_bucket_owner`
resource "aws_s3_bucket_versioning" "this" {
  region = var.region

  bucket = aws_s3_bucket.this.bucket

  mfa = (var.versioning.status == "ENABLED"
    ? var.versioning.mfa_deletion.device
    : null
  )

  versioning_configuration {
    status = local.versioning_status[var.versioning.status]
    mfa_delete = (var.versioning.status == "ENABLED"
      ? (var.versioning.mfa_deletion.enabled ? "Enabled" : "Disabled")
      : null
    )
  }
}


###################################################
# Object Lock for S3 Bucket
###################################################

# INFO: Not supported attributes
# - `expected_bucket_owner`
# INFO: Deprecated attributes
# - `token`
resource "aws_s3_bucket_object_lock_configuration" "this" {
  count = var.object_lock.enabled ? 1 : 0

  region = var.region

  bucket              = aws_s3_bucket_versioning.this.bucket
  object_lock_enabled = "Enabled"

  dynamic "rule" {
    for_each = var.object_lock.default_retention != null ? [var.object_lock.default_retention] : []

    content {
      default_retention {
        mode  = rule.value.mode
        days  = rule.value.unit != "YEARS" ? rule.value.value : null
        years = rule.value.unit == "YEARS" ? rule.value.value : null
      }
    }
  }

  lifecycle {
    ignore_changes = [
      token,
    ]
  }
}


###################################################
# Lifecycle Rules for S3 Bucket
###################################################

# INFO: Not supported attributes
# - `expected_bucket_owner`
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = length(var.lifecycle_rules) > 0 ? 1 : 0

  region = var.region

  bucket = aws_s3_bucket_versioning.this.bucket

  transition_default_minimum_object_size = var.lifecycle_transition_default_min_object_size_strategy

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload != null ? [rule.value.abort_incomplete_multipart_upload] : []

        content {
          days_after_initiation = abort_incomplete_multipart_upload.value.days
        }
      }

      ## Empty Filter
      dynamic "filter" {
        for_each = sum([
          rule.value.prefix != "" ? 1 : 0,
          length(rule.value.tags) != 0 ? 1 : 0,
          rule.value.min_object_size != null ? 1 : 0,
          rule.value.max_object_size != null ? 1 : 0,
        ]) == 0 ? ["go"] : []

        content {
          prefix = rule.value.prefix
        }
      }

      ## Single Filter
      dynamic "filter" {
        for_each = length(rule.value.tags) == 0 && sum([
          rule.value.prefix != "" ? 1 : 0,
          rule.value.min_object_size != null ? 1 : 0,
          rule.value.max_object_size != null ? 1 : 0,
        ]) == 1 ? ["go"] : []

        content {
          prefix = rule.value.prefix

          object_size_greater_than = rule.value.min_object_size
          object_size_less_than    = rule.value.max_object_size
        }
      }

      ## Multi Filter
      dynamic "filter" {
        for_each = sum([
          rule.value.prefix != "" ? 1 : 0,
          length(rule.value.tags) != 0 ? 2 : 0,
          rule.value.min_object_size != null ? 1 : 0,
          rule.value.max_object_size != null ? 1 : 0,
        ]) > 1 ? ["go"] : []

        content {
          and {
            prefix = rule.value.prefix
            tags   = rule.value.tags != {} ? rule.value.tags : null

            object_size_greater_than = rule.value.min_object_size
            object_size_less_than    = rule.value.max_object_size
          }
        }
      }

      dynamic "transition" {
        for_each = rule.value.transitions

        content {
          date = transition.value.date
          days = transition.value.days

          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transitions

        content {
          noncurrent_days           = noncurrent_version_transition.value.days
          newer_noncurrent_versions = noncurrent_version_transition.value.count

          storage_class = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []

        content {
          date = expiration.value.date
          days = expiration.value.days

          expired_object_delete_marker = expiration.value.expired_object_delete_marker ? true : null
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []

        content {
          noncurrent_days           = noncurrent_version_expiration.value.days
          newer_noncurrent_versions = noncurrent_version_expiration.value.count
        }
      }
    }
  }
}


###################################################
# Replication Rules for S3 Bucket
###################################################

# INFO: Not supported attributes
# - `prefix`
# - `token`
# - `rule.existing_object_replication`: Not supported by Amazon S3 at this time and should not be included in your rule configurations. Specifying this parameter will result in MalformedXML errors
resource "aws_s3_bucket_replication_configuration" "this" {
  count = length(var.replication_rules) > 0 ? 1 : 0

  region = var.region

  role   = local.replication_iam_role
  bucket = aws_s3_bucket_versioning.this.bucket

  dynamic "rule" {
    for_each = var.replication_rules

    content {
      id       = rule.value.id
      priority = rule.value.priority
      status   = rule.value.enabled ? "Enabled" : "Disabled"

      delete_marker_replication {
        status = rule.value.delete_marker_replication_enabled ? "Enabled" : "Disabled"
      }

      source_selection_criteria {
        dynamic "sse_kms_encrypted_objects" {
          for_each = rule.value.sse_kms_encrypted_objects_replication.enabled ? ["go"] : []

          content {
            status = "Enabled"
          }
        }

        replica_modifications {
          status = rule.value.replica_modification_sync_enabled ? "Enabled" : "Disabled"
        }
      }

      # INFO: Not supported yet.
      # dynamic "existing_object_replication" {
      #   for_each = rule.value.existing_object_replication_enabled ? ["go"] : []
      #
      #   content {
      #     status = "Enabled"
      #   }
      # }

      ## Empty Filter
      dynamic "filter" {
        for_each = sum([
          rule.value.prefix != "" ? 1 : 0,
          length(rule.value.tags) != 0 ? 1 : 0,
        ]) == 0 ? ["go"] : []

        content {}
      }

      ## Single Filter (Prefix)
      dynamic "filter" {
        for_each = anytrue([
          length(rule.value.tags) == 0 && rule.value.prefix != "",
        ]) ? ["go"] : []

        content {
          prefix = rule.value.prefix
        }
      }

      ## Single Filter (Tag)
      dynamic "filter" {
        for_each = anytrue([
          length(rule.value.tags) == 1 && rule.value.prefix == "",
        ]) ? ["go"] : []

        content {
          dynamic "tag" {
            for_each = rule.value.tags

            content {
              key   = tag.key
              value = tag.value == null ? "" : tag.value
            }
          }
        }
      }

      ## Multi Filter
      dynamic "filter" {
        for_each = anytrue([
          length(rule.value.tags) >= 2,
          length(rule.value.tags) != 0 && rule.value.prefix != "",
        ]) ? ["go"] : []

        content {
          and {
            prefix = rule.value.prefix
            tags   = rule.value.tags
          }
        }
      }

      destination {
        bucket        = provider::aws::arn_build("aws", "s3", "", "", rule.value.destination.bucket)
        account       = coalesce(rule.value.destination.account, local.account_id)
        storage_class = rule.value.destination.storage_class

        dynamic "access_control_translation" {
          for_each = rule.value.ownership_translation_enabled ? ["go"] : []

          content {
            owner = "Destination"
          }
        }

        dynamic "encryption_configuration" {
          for_each = rule.value.sse_kms_encrypted_objects_replication.enabled ? ["go"] : []

          content {
            replica_kms_key_id = rule.value.sse_kms_encrypted_objects_replication.kms_key
          }
        }

        replication_time {
          status = rule.value.replication_time_control.enabled ? "Enabled" : "Disabled"

          time {
            minutes = rule.value.replication_time_control.time_threshold
          }
        }

        metrics {
          status = rule.value.metrics.enabled ? "Enabled" : "Disabled"

          event_threshold {
            minutes = rule.value.metrics.time_threshold
          }
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
      error_message = "Replication rules require versioning to be enabled on the source bucket."
    }
  }
}
