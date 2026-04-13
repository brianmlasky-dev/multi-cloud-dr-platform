# ─────────────────────────────────────────
# Security Module Variables
# ─────────────────────────────────────────

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "multi-cloud-dr-platform"
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}
