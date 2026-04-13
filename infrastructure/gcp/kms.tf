# ─────────────────────────────────────────
# GCP KMS - Customer-Managed Encryption Keys
# Used for GCS bucket server-side encryption (CMEK)
# ─────────────────────────────────────────

resource "google_kms_key_ring" "main" {
  name     = "${var.project_name}-keyring"
  location = var.gcp_region
}

resource "google_kms_crypto_key" "storage" {
  name            = "${var.project_name}-storage-key"
  key_ring        = google_kms_key_ring.main.id
  purpose         = "ENCRYPT_DECRYPT"
  rotation_period = "7776000s" # 90-day rotation

  lifecycle {
    prevent_destroy = true
  }
}

# Grant the GCS service account permission to use the CMEK key
data "google_storage_project_service_account" "main" {}

resource "google_kms_crypto_key_iam_binding" "storage_encryption" {
  crypto_key_id = google_kms_crypto_key.storage.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${data.google_storage_project_service_account.main.email_address}",
  ]
}
