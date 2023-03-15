provider "aws" {
  region = "us-east-1"
}


###################################################
# QuickSight Groups
###################################################

module "group__dev" {
  source = "../../modules/quicksight-group"
  # source  = "tedilabs/data/aws//modules/quicksight-group"
  # version = "~> 0.3.0"

  name        = "dev"
  description = "Dev Gorup."
  namespace   = "default"

  members = []
}

module "group__ops" {
  source = "../../modules/quicksight-group"
  # source  = "tedilabs/data/aws//modules/quicksight-group"
  # version = "~> 0.3.0"

  name        = "ops"
  description = "Ops Gorup."
  namespace   = "default"

  members = []
}
