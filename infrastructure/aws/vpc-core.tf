module "vpc" {
  source       = "../modules/vpc"
  cidr_block   = "10.0.0.0/16"
  project_name = var.project_name
}
