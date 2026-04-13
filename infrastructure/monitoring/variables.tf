# ─────────────────────────────────────────
# Monitoring Module Variables
# ─────────────────────────────────────────

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

variable "alert_email" {
  description = "Email address to receive monitoring alert notifications"
  type        = string
  default     = ""
}
