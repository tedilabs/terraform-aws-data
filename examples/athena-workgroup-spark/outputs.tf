output "workgroups" {
  value = {
    pyspark = module.pyspark
    spark   = module.spark
  }
}
