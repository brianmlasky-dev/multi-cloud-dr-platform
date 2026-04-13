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
    default_kms_key_name = google_kms_crypto_key.storage.id
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

  # Archive after 1 year; retain indefinitely for PCI-DSS audit log compliance (12-month minimum).
  # Do NOT add a Delete rule here — deleting audit data violates PCI-DSS Req. 10.7.
  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
  }

  depends_on = [google_kms_crypto_key_iam_binding.storage_encryption]
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
