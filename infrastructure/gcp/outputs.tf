# ─────────────────────────────────────────
# GCP Outputs
# ─────────────────────────────────────────

output "vpc_network_name" {
  description = "GCP VPC network name"
  value       = google_compute_network.main.name
}

output "cloud_run_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_v2_service.app.uri
}

output "cloud_sql_connection_name" {
  description = "Cloud SQL instance connection name"
  value       = google_sql_database_instance.main.connection_name
  sensitive   = true
}

output "cloud_sql_private_ip" {
  description = "Cloud SQL private IP address"
  value       = google_sql_database_instance.main.private_ip_address
  sensitive   = true
}

output "gcs_bucket_name" {
  description = "GCS DR storage bucket name"
  value       = google_storage_bucket.app.name
}
