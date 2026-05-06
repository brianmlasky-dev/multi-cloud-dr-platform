variable "cidr_block" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
}

variable "aws_region" {
  description = "AWS region for AZ suffixes"
  type        = string
  default     = "us-east-1"
}
