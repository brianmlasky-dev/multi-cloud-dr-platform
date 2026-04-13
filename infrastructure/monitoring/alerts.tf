# ─────────────────────────────────────────
# GCP Monitoring - Alerts & Uptime Checks
# ─────────────────────────────────────────

resource "google_monitoring_uptime_check_config" "primary" {
  display_name = "northstar-primary-uptime"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path         = "/health"
    port         = 443
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.gcp_project_id
      host       = "app.northstarcommerce.com"
    }
  }
}

resource "google_monitoring_uptime_check_config" "standby" {
  display_name = "northstar-standby-uptime"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path         = "/health"
    port         = 443
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.gcp_project_id
      host       = "standby.northstarcommerce.com"
    }
  }
}

resource "google_monitoring_alert_policy" "high_latency" {
  display_name = "High Latency Alert"
  combiner     = "OR"

  conditions {
    display_name = "Request latency > 2s"
    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 2000
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = []
  alert_strategy {
    auto_close = "1800s"
  }
}

resource "google_monitoring_alert_policy" "uptime_failure" {
  display_name = "Uptime Check Failure"
  combiner     = "OR"

  conditions {
    display_name = "Primary endpoint down"
    condition_threshold {
      filter          = "metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\""
      duration        = "60s"
      comparison      = "COMPARISON_LT"
      threshold_value = 1
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_FRACTION_TRUE"
      }
    }
  }

  notification_channels = []
  alert_strategy {
    auto_close = "1800s"
  }
}

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "northstar-dr-platform"
}
