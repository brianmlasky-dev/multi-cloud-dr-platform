terraform {
  backend "s3" {
    bucket         = "northstar-dr-terraform-state"
    key            = "multi-cloud-dr/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "northstar-terraform-locks"
  }
}
