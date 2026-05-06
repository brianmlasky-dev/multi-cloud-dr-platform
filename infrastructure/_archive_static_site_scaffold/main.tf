terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment after first apply to enable remote state
  # backend "s3" {
  #   bucket         = "YOUR_TERRAFORM_STATE_BUCKET"
  #   key            = "portfolio-site/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "portfolio-static-site"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

module "s3_cloudfront" {
  source = "./modules/s3_cloudfront"

  bucket_name = var.bucket_name
  environment = var.environment
  aws_region  = var.aws_region
}
