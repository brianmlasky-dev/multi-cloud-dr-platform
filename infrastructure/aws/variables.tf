variable "project_name" {
  description = "Project name"
  type        = string
  default     = "multi-cloud-dr"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "northstar_admin"
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password — override via TF_VAR_db_password env var"
  type        = string
  sensitive   = true
  # No default — must be set via environment variable or tfvars
  # export TF_VAR_db_password="your-secure-password"
}
