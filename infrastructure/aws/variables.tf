variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "northstar"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "domain_name" {
  description = "Primary domain name for Route53 and ACM"
  type        = string
  default     = "brian-lasky.com"
}

variable "db_username" {
  description = "RDS PostgreSQL master username"
  type        = string
  default     = "northstar_admin"
}

variable "db_password" {
  description = "RDS PostgreSQL master password"
  type        = string
  sensitive   = true
}

variable "primary_alb_dns" {
  description = "DNS name of the primary AWS ALB for Route53 failover routing"
  type        = string
  default     = ""
}

variable "gcp_cloudrun_fqdn" {
  description = "Fully qualified domain name of the GCP Cloud Run failover endpoint"
  type        = string
  default     = ""
}
