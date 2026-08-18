provider "aws" {
  region = "us-east-1"
}


###################################################
# Athena Workgroup with IAM Identity Center Authentication
###################################################

module "iam_identity_center" {
  source = "../../modules/athena-workgroup"
  # source  = "tedilabs/data/aws//modules/athena-workgroup"
  # version = "~> 0.9.0"

  name        = "iam-identity-center"
  description = "This workgroup is created with IAM Identity Center authentication."

  analytics_engine = {
    version = "ATHENA_V3"
  }

  iam_identity_center = {
    enabled = true
    # instance = "arn:aws:sso:::instance/ssoins-1234567890abcdef"
  }

  query_result = {
    management_mode        = "CUSTOMER_MANAGED"
    override_client_config = true

    s3_access_grants = {
      enabled                   = true
      user_level_prefix_enabled = true
    }

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

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}
