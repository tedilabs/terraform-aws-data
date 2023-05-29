provider "aws" {
  region = "us-east-1"
}


###################################################
# Glue Data Catalog
###################################################

module "data_catalog" {
  source = "../../modules/glue-data-catalog"
  # source  = "tedilabs/data/aws//modules/glue-data-catalog"
  # version = "~> 0.2.0"

  encryption_for_connection_passwords = {
    enabled = false
  }
  encryption_at_rest = {
    enabled = false
  }

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}
