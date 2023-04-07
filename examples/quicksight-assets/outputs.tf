output "folders" {
  description = "A list of QuickSight folders."
  value = {
    dev  = module.folder__dev
    test = module.folder__test
  }
}
