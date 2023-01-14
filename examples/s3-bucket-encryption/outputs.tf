output "buckets" {
  value = {
    "AES256"  = module.bucket
    "AWS_KMS" = module.bucket_kms
  }
}

output "kms_key" {
  value = module.kms_key
}
