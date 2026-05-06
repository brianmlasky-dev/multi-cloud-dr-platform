variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
}

variable "environment" {
  description = "Environment (dev, production)"
  type        = string
  validation {
    condition     = contains(["dev", "production"], var.environment)
    error_message = "Environment must be 'dev' or 'production'."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
