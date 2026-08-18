provider "aws" {
  region = "us-east-1"
}

resource "aws_kms_key" "this" {
  description             = "Key to encrypt Athena Spark workgroup contents and logs."
  deletion_window_in_days = 7

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}


###################################################
# S3 Bucket for Calculation Results and Logs
###################################################

module "bucket" {
  source  = "tedilabs/s3/aws//modules/bucket"
  version = "~> 0.1.0"

  name          = "tedilabs-terraform-aws-data-examples-athena-workgroup-spark"
  force_destroy = true

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}


###################################################
# Athena Workgroup with PySpark Engine
###################################################

module "pyspark" {
  source = "../../modules/athena-workgroup"
  # source  = "tedilabs/data/aws//modules/athena-workgroup"
  # version = "~> 0.9.0"

  name        = "pyspark"
  description = "This workgroup is created with PySpark engine version 3."

  analytics_engine = {
    version = "PYSPARK_V3"
  }

  customer_content_encryption = {
    enabled = true
    kms_key = aws_kms_key.this.arn
  }

  logging = {
    cloudwatch = {
      enabled                = true
      log_group              = "/aws/athena/sessions/pyspark"
      log_stream_name_prefix = "session-"
      log_types = {
        "SPARK_DRIVER" = ["STDOUT", "STDERR"]
      }
    }
    managed = {
      enabled     = true
      sse_kms_key = aws_kms_key.this.arn
    }
    s3_bucket = {
      enabled  = true
      location = "s3://${module.bucket.name}/athena-spark-logs/"
    }
  }

  default_spark_execution_role = {
    enabled     = true
    name        = "athena-workgroup-spark-pyspark-example"
    description = "Execution role for the example PySpark workgroup."
  }

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}


###################################################
# Athena Workgroup with Apache Spark Engine
###################################################

module "spark" {
  source = "../../modules/athena-workgroup"
  # source  = "tedilabs/data/aws//modules/athena-workgroup"
  # version = "~> 0.9.0"

  name        = "spark"
  description = "This workgroup is created with Apache Spark version 3.5."

  analytics_engine = {
    version = "SPARK_V3.5"
  }

  logging = {
    managed = {
      enabled = true
    }
  }

  # Use an existing IAM Role instead of creating a default one.
  # default_spark_execution_role = {
  #   enabled = false
  # }
  # spark_execution_role = "arn:aws:iam::123456789012:role/athena-spark-execution-role"

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}
