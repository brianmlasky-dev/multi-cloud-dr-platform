# ─────────────────────────────────────────
# GCP Static IP - Standby Endpoint
#
# A stable global IP for the GCP standby service, referenced by the
# Route 53 secondary failover record in the AWS Terraform workspace
# (infrastructure/aws/route53.tf → var.gcp_standby_ip).
#
# After applying, pass the output to the AWS workspace:
#   terraform output standby_static_ip
# ─────────────────────────────────────────

resource "google_compute_global_address" "standby" {
  name         = "${var.project_name}-standby-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"

  description = "Global static IP for the standby DR endpoint. Used by Route 53 failover record."
}
