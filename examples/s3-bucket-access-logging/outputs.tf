output "buckets" {
  value = {
    source = module.source_bucket
    target = module.target_bucket
  }
}
