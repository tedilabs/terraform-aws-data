provider "aws" {
  region = "us-east-1"
}


###################################################
# QuickSight Folders
###################################################

module "folder__dev" {
  source = "../../modules/quicksight-folder"
  # source  = "tedilabs/data/aws//modules/quicksight-folder"
  # version = "~> 0.5.0"

  name          = "dev"
  display_name  = "Dev Folder"
  parent_folder = null

  permissions = []

  assets = {
    analyses   = []
    dashboards = []
    datasets   = []
  }

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}

module "folder__test" {
  source = "../../modules/quicksight-folder"
  # source  = "tedilabs/data/aws//modules/quicksight-folder"
  # version = "~> 0.5.0"

  name          = "test"
  display_name  = "Test Folder"
  parent_folder = null

  permissions = []

  assets = {
    analyses   = []
    dashboards = []
    datasets   = []
  }

  tags = {
    "project" = "terraform-aws-data-examples"
  }
}
