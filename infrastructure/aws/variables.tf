# ─────────────────────────────────────────
# AWS Input Variables
# ─────────────────────────────────────────

variable "aws_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "multi-cloud-dr"
}

variable "vpc_cidr" {
  description = "CIDR block for the AWS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "app_image" {
  description = "Docker image URI for ECS task"
  type        = string
  default     = "nginx:1.27.4"
}

variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "crestline_db"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "gcp_standby_ip" {
  description = "Static IP address of the GCP standby load balancer (output from GCP Terraform workspace)"
  type        = string
  default     = ""
}
