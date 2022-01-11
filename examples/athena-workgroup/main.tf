provider "aws" {
  region = "us-east-1"
}


###################################################
# Athena Workgroup with simple configurations
###################################################

module "simple" {
  source  = "tedilabs/data/aws//modules/athena-workgroup"
  version = "~> 0.1.0"

  name = "simple"

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}


###################################################
# Athena Workgroup with full configurations
###################################################

module "full" {
  source  = "tedilabs/data/aws//modules/athena-workgroup"
  version = "~> 0.1.0"

  name        = "full"
  description = "This workgroup is created with full configurtaions."

  enabled       = true
  force_destroy = true

  client_config_enabled                     = false
  cloudwatch_metrics_enabled                = true
  query_on_s3_requester_pays_bucket_enabled = false

  per_query_data_usage_limit = 64 * 1024 * 1024

  query_result = {
    s3_bucket          = "tedilabs-terraform-aws-data-examples-athena-workgroup"
    s3_key_prefix      = "/athena-query-results"
    encryption_enabled = true
    encryption_mode    = "SSE_S3"
    encryption_kms_key = null
  }

  named_queries = [
    {
      name     = "hello-world"
      database = "default"
      query    = "SELECT 1"
    }
  ]

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}
