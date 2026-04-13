# ─────────────────────────────────────────
# Cloud Run - Standby Containerized App
# ─────────────────────────────────────────

resource "google_cloud_run_v2_service" "app" {
  name     = "${var.project_name}-app"
  location = var.gcp_region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    scaling {
      min_instance_count = var.cloud_run_min_instances
      max_instance_count = var.cloud_run_max_instances
    }

    containers {
      image = var.app_image

      ports {
        container_port = 80
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      env {
        name  = "DB_HOST"
        value = google_sql_database_instance.main.private_ip_address
      }

      env {
        name  = "DB_NAME"
        value = var.db_name
      }

      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }
    }

    vpc_access {
      network_interfaces {
        network    = google_compute_network.main.name
        subnetwork = google_compute_subnetwork.main.name
      }
      egress = "PRIVATE_RANGES_ONLY"
    }
  }
}

# Allow unauthenticated access (public app)
resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = var.gcp_project_id
  location = var.gcp_region
  name     = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
