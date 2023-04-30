output "namespaces" {
  description = "A list of QuickSight namespaces."
  value = {
    "3rd-party" = module.namespace__3rd_party
  }
}

output "groups" {
  description = "A list of QuickSight groups."
  value = {
    "dev"       = module.group__dev
    "ops"       = module.group__ops
    "3rd-party" = module.group__3rd_party
  }
}
