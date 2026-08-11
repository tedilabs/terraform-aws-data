provider "aws" {
  region = "us-east-1"
}


###################################################
# Athena Workgroup with simple configurations
###################################################

module "simple" {
  source = "../../modules/athena-workgroup"
  # source  = "tedilabs/data/aws//modules/athena-workgroup"
  # version = "~> 0.8.0"

  name = "simple"

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}


###################################################
# Athena Workgroup with full configurations
###################################################

module "full" {
  source = "../../modules/athena-workgroup"
  # source  = "tedilabs/data/aws//modules/athena-workgroup"
  # version = "~> 0.8.0"

  name        = "full"
  description = "This workgroup is created with full configurtaions."

  enabled       = true
  force_destroy = true

  cloudwatch_metrics_enabled                = true
  query_on_s3_requester_pays_bucket_enabled = false

  per_query_data_usage_limit = 64 * 1024 * 1024

  query_result = {
    management_mode        = "CUSTOMER_MANAGED"
    override_client_config = true

    customer_managed_query_result = {
      s3_bucket = {
        name       = "tedilabs-terraform-aws-data-examples-athena-workgroup"
        key_prefix = "athena-query-results/"
      }
      encryption = {
        enabled = true
        mode    = "SSE_S3"
      }
    }
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
