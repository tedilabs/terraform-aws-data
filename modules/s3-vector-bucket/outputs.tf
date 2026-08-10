output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_s3vectors_vector_bucket.this.region
}

output "name" {
  description = "The name of the vector bucket."
  value       = aws_s3vectors_vector_bucket.this.vector_bucket_name
}

output "arn" {
  description = "The ARN of the vector bucket."
  value       = aws_s3vectors_vector_bucket.this.vector_bucket_arn
}

output "created_at" {
  description = "Date and time when the vector bucket was created."
  value       = aws_s3vectors_vector_bucket.this.creation_time
}

output "encryption" {
  description = "The configuration for the Server-Side Encryption of the vector bucket."
  value = {
    type = {
      for k, v in local.encryption_type :
      v => k
    }[one(aws_s3vectors_vector_bucket.this.encryption_configuration[*].sse_type)]
    kms_key = one(aws_s3vectors_vector_bucket.this.encryption_configuration[*].kms_key_arn)
  }
}

output "indexes" {
  description = "The vector indexes created in the vector bucket."
  value = {
    for name, index in aws_s3vectors_index.this :
    name => {
      arn  = index.index_arn
      name = index.index_name

      data_type       = index.data_type
      dimension       = index.dimension
      distance_metric = index.distance_metric

      encryption = merge(
        {
          override = length(index.encryption_configuration) > 0
        },
        (length(index.encryption_configuration) > 0
          ? {
            type = {
              for k, v in local.encryption_type :
              v => k
            }[index.encryption_configuration[0].sse_type]
            kms_key = index.encryption_configuration[0].kms_key_arn
          }
          : {}
        )
      )

      metadata = {
        non_filterable_keys = try(index.metadata_configuration[0].non_filterable_metadata_keys, [])
      }

      created_at = index.creation_time
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

# output "debug" {
#   value = {
#     bucket = {
#       for k, v in aws_s3vectors_vector_bucket.this :
#       k => v
#       if !contains(["tags", "tags_all", "region", "creation_time", "force_destroy", "vector_bucket_name", "vector_bucket_arn", "encryption_configuration"], k)
#     }
#     policy = (length(aws_s3vectors_vector_bucket_policy.this) > 0
#       ? {
#         for k, v in aws_s3vectors_vector_bucket_policy.this[0] :
#         k => v
#         if !contains(["vector_bucket_arn", "policy", "region"], k)
#       }
#       : null
#     )
#     indexes = {
#       for name, index in aws_s3vectors_index.this :
#       name => {
#         for k, v in index :
#         k => v
#         if !contains(["tags", "tags_all", "region", "vector_bucket_name", "index_name", "data_type", "dimension", "distance_metric", "encryption_configuration", "index_arn", "creation_time", "metadata_configuration"], k)
#       }
#     }
#   }
# }
