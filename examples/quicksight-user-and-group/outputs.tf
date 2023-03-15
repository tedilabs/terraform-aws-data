output "groups" {
  description = "A list of QuickSight groups."
  value = {
    dev = module.group__dev
    ops = module.group__ops
  }
}
