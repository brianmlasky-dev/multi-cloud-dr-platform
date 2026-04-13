# ─────────────────────────────────────────
# GCS Bucket - Backup Storage & DR Assets
# ─────────────────────────────────────────

resource "google_storage_bucket" "app" {
  name          = "${var.project_name}-dr-storage"
  location      = var.gcp_region
  force_destroy = false

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = ""
  }

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "Delete"
    }
  }
}

# Sync bucket from AWS S3 via scheduled job
resource "google_storage_bucket" "terraform_state" {
  name          = "multi-cloud-dr-terraform-state"
  location      = var.gcp_region
  force_destroy = false

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
}
