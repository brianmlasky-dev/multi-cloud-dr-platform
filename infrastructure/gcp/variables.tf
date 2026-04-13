# ─────────────────────────────────────────
# GCP Input Variables
# ─────────────────────────────────────────

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "northstar-dr-platform"
}

variable "gcp_region" {
  description = "Primary GCP region for standby deployment"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "northstar-dr"
}

variable "vpc_cidr" {
  description = "CIDR block for the GCP VPC subnet"
  type        = string
  default     = "10.1.0.0/16"
}

variable "db_username" {
  description = "Cloud SQL master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Cloud SQL master password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "northstar_db"
}

variable "app_image" {
  description = "Docker image URI for Cloud Run service"
  type        = string
  default     = "nginx:latest"
}

variable "cloud_run_min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
  default     = 0
}

variable "cloud_run_max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 5
}
