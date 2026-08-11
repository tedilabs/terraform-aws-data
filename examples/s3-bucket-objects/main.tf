provider "aws" {
  region = "us-east-1"
}


###################################################
# S3 Bucket
###################################################

resource "random_string" "this" {
  length  = 32
  special = false
  numeric = false
  upper   = false
}

locals {
  bucket_name = random_string.this.id
}

module "bucket" {
  source = "../../modules/s3-bucket"
  # source  = "tedilabs/data/aws//modules/s3-bucket"
  # version = "~> 0.8.0"

  name          = local.bucket_name
  force_destroy = true

  objects = {
    files = [
      {
        key     = "config/app.json"
        content = jsonencode({ env = "example" })
      },
      {
        key           = "docs/index.html"
        source        = "${path.module}/files/index.html"
        cache_control = "max-age=300"
      },
    ]
    directories = [
      {
        path             = "${path.module}/files"
        key_prefix       = "static/"
        exclude_patterns = [".*"]
      },
    ]
  }

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}
