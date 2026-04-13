terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state stored in S3 (exam topic: backends)
  backend "s3" {
    bucket = "northstar-dr-terraform-state"
    key    = "aws/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "multi-cloud-dr-platform"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "Brian M. Lasky"
    }
  }
}
