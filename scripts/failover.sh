#!/usr/bin/env bash
# ─────────────────────────────────────────
# Crestline Financial — DR Failover Script
# Author: Brian M. Lasky
# Organization: Crestline Financial
#
# Usage:
#   ./failover.sh [--dry-run] [--direction aws-to-gcp|gcp-to-aws]
#
# Environment variables required:
#   AWS_REGION              AWS region (default: us-east-1)
#   GCP_PROJECT_ID          GCP project ID (default: multi-cloud-dr-platform)
#   GCP_REGION              GCP region (default: us-central1)
#   ROUTE53_HOSTED_ZONE_ID  Route 53 hosted zone ID
#
# For failback (gcp-to-aws), also set:
#   GCP_STANDBY_IP          Static IP of GCP standby (for Route 53 record restore)
# ─────────────────────────────────────────
set -euo pipefail

# ── Defaults ────────────────────────────────────────────────────────────────
AWS_REGION="${AWS_REGION:-us-east-1}"
GCP_PROJECT_ID="${GCP_PROJECT_ID:-multi-cloud-dr-platform}"
GCP_REGION="${GCP_REGION:-us-central1}"

PROJECT_NAME="multi-cloud-dr"
ECS_CLUSTER="${PROJECT_NAME}-cluster"
ECS_SERVICE="${PROJECT_NAME}-service"
CLOUD_SQL_INSTANCE="${PROJECT_NAME}-postgres"
CLOUD_RUN_SERVICE="${PROJECT_NAME}-app"

PRIMARY_HEALTH_URL="https://app.crestlinefinancial.com/health"
STANDBY_HEALTH_URL="https://standby.crestlinefinancial.com/health"

DRY_RUN=false
DIRECTION="aws-to-gcp"

# ── Argument parsing ─────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --direction)
      DIRECTION="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      echo "Usage: $0 [--dry-run] [--direction aws-to-gcp|gcp-to-aws]"
      exit 1
      ;;
  esac
done

# ── Helpers ──────────────────────────────────────────────────────────────────
log()  { echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] $*"; }
info() { log "INFO  $*"; }
warn() { log "WARN  $*"; }
die()  { log "ERROR $*"; exit 1; }

run() {
  if [[ "$DRY_RUN" == "true" ]]; then
    log "DRY-RUN  $*"
  else
    info "Running: $*"
    eval "$@"
  fi
}

check_dependency() {
  command -v "$1" &>/dev/null || die "Required tool not found: $1. Please install it before running this script."
}

# ── Dependency checks ─────────────────────────────────────────────────────────
check_dependency aws
check_dependency gcloud
check_dependency curl
check_dependency dig

# ── Health check helper ───────────────────────────────────────────────────────
check_health() {
  local url="$1"
  local label="$2"
  info "Checking health of $label ($url) ..."
  if curl --silent --fail --max-time 10 "$url" > /dev/null 2>&1; then
    info "$label is HEALTHY"
    return 0
  else
    warn "$label is UNHEALTHY or unreachable"
    return 1
  fi
}

# ── Route 53 helper ───────────────────────────────────────────────────────────
update_route53_weights() {
  local zone_id="$1"
  local primary_weight="$2"  # 0 = disabled, 1 = enabled
  local secondary_weight="$3"

  [[ -z "$zone_id" ]] && die "ROUTE53_HOSTED_ZONE_ID must be set"

  local change_batch
  change_batch=$(cat <<EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "app.crestlinefinancial.com",
        "Type": "A",
        "SetIdentifier": "primary",
        "Failover": "PRIMARY",
        "HealthCheckId": "$(aws route53 list-health-checks \
            --query "HealthChecks[?HealthCheckConfig.FullyQualifiedDomainName=='app.crestlinefinancial.com'].Id" \
            --output text --region "$AWS_REGION")"
      }
    }
  ]
}
EOF
)

  # For failover routing the records already exist; we just need to disable/enable
  # the primary health check so Route 53 routes to secondary automatically.
  # We achieve this by updating the health check threshold to 1 (enable) or 0 (fail fast).
  local primary_hc_id
  primary_hc_id=$(aws route53 list-health-checks \
    --query "HealthChecks[?HealthCheckConfig.FullyQualifiedDomainName=='app.crestlinefinancial.com'].Id" \
    --output text)

  if [[ -n "$primary_hc_id" ]]; then
    if [[ "$primary_weight" -eq 0 ]]; then
      info "Disabling primary Route 53 health check to force failover to GCP ..."
      run aws route53 update-health-check \
        --health-check-id "$primary_hc_id" \
        --failure-threshold 1 \
        --regions us-east-1 us-west-2 eu-west-1
    else
      info "Restoring primary Route 53 health check failure threshold ..."
      run aws route53 update-health-check \
        --health-check-id "$primary_hc_id" \
        --failure-threshold 3
    fi
  else
    warn "Could not locate primary health check ID; Route 53 update skipped."
  fi
}

# ════════════════════════════════════════════════════════════════════════════
# FAILOVER: AWS → GCP
# ════════════════════════════════════════════════════════════════════════════
failover_aws_to_gcp() {
  info "═══════════════════════════════════════════════════════"
  info " FAILOVER: AWS (Primary) → GCP (Standby)"
  info "═══════════════════════════════════════════════════════"
  [[ "$DRY_RUN" == "true" ]] && warn "DRY-RUN mode — no real changes will be made."

  # ── Step 1: Verify the outage ──────────────────────────────────────────────
  info "Step 1: Verifying outage ..."
  if check_health "$PRIMARY_HEALTH_URL" "AWS Primary"; then
    warn "AWS Primary appears healthy. Proceeding only if this is an intentional test."
    read -r -p "AWS primary is responding. Continue failover anyway? [y/N] " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { info "Failover cancelled."; exit 0; }
  fi

  if ! check_health "$STANDBY_HEALTH_URL" "GCP Standby"; then
    die "GCP Standby is also unreachable. Aborting failover — investigate standby health first."
  fi

  # ── Step 2: Confirm last DB sync ───────────────────────────────────────────
  info "Step 2: Checking database sync status ..."
  if [[ -x "$(dirname "$0")/sync-db.sh" ]]; then
    "$(dirname "$0")/sync-db.sh" --status || warn "Could not verify DB sync status; review RPO before proceeding."
  else
    warn "sync-db.sh not found or not executable; skipping DB sync check."
  fi

  # ── Step 3: Activate Cloud SQL (ensure Always-On) ──────────────────────────
  info "Step 3: Activating Cloud SQL in GCP ..."
  run gcloud sql instances patch "$CLOUD_SQL_INSTANCE" \
    --activation-policy=ALWAYS \
    --project="$GCP_PROJECT_ID"

  # ── Step 4: Scale up Cloud Run and enable public access ────────────────────
  info "Step 4: Scaling up Cloud Run service ..."
  run gcloud run services update "$CLOUD_RUN_SERVICE" \
    --min-instances=2 \
    --max-instances=10 \
    --region="$GCP_REGION" \
    --project="$GCP_PROJECT_ID"

  info "Step 4b: Granting public invoker access to Cloud Run ..."
  run gcloud run services add-iam-policy-binding "$CLOUD_RUN_SERVICE" \
    --region="$GCP_REGION" \
    --project="$GCP_PROJECT_ID" \
    --member="allUsers" \
    --role="roles/run.invoker"

  # ── Step 5: Force Route 53 failover ───────────────────────────────────────
  info "Step 5: Triggering Route 53 DNS failover ..."
  if [[ -n "${ROUTE53_HOSTED_ZONE_ID:-}" ]]; then
    update_route53_weights "$ROUTE53_HOSTED_ZONE_ID" 0 1
  else
    warn "ROUTE53_HOSTED_ZONE_ID not set — Route 53 update skipped. Set the variable and re-run step 5 manually."
  fi

  # ── Step 6: Verify failover ────────────────────────────────────────────────
  if [[ "$DRY_RUN" == "false" ]]; then
    info "Step 6: Waiting 30 s for DNS TTL propagation ..."
    sleep 30
    info "Step 6: Verifying DNS resolution ..."
    dig +short app.crestlinefinancial.com || warn "DNS lookup failed; TTL may still be propagating."
    check_health "$PRIMARY_HEALTH_URL" "Failover endpoint (via Route 53)" \
      && info "✓ FAILOVER SUCCESSFUL — traffic is now served from GCP" \
      || warn "Health check on app URL still failing; verify DNS TTL and Cloud Run status."
  fi

  info "═══════════════════════════════════════════════════════"
  info " Failover complete. Update Terraform var cloud_run_public_access=true"
  info " in infrastructure/gcp to persist the IAM change across terraform applies."
  info "═══════════════════════════════════════════════════════"
}

# ════════════════════════════════════════════════════════════════════════════
# FAILBACK: GCP → AWS
# ════════════════════════════════════════════════════════════════════════════
failback_gcp_to_aws() {
  info "═══════════════════════════════════════════════════════"
  info " FAILBACK: GCP (Active) → AWS (Primary)"
  info "═══════════════════════════════════════════════════════"
  [[ "$DRY_RUN" == "true" ]] && warn "DRY-RUN mode — no real changes will be made."

  # ── Step 1: Verify AWS environment health ─────────────────────────────────
  info "Step 1: Verifying AWS environment health ..."
  info "Checking ECS service status ..."
  run aws ecs describe-services \
    --cluster "$ECS_CLUSTER" \
    --services "$ECS_SERVICE" \
    --region "$AWS_REGION" \
    --query "services[0].{Status:status,DesiredCount:desiredCount,RunningCount:runningCount}" \
    --output table

  # ── Step 2: Sync data from GCP back to AWS RDS ────────────────────────────
  info "Step 2: Syncing data from GCP → AWS ..."
  if [[ -x "$(dirname "$0")/sync-db.sh" ]]; then
    run "$(dirname "$0")/sync-db.sh" gcp-to-aws
  else
    warn "sync-db.sh not found or not executable; perform manual data sync before failback."
  fi

  # ── Step 3: Restore Route 53 to primary ──────────────────────────────────
  info "Step 3: Restoring Route 53 health check to re-enable primary failover record ..."
  if [[ -n "${ROUTE53_HOSTED_ZONE_ID:-}" ]]; then
    update_route53_weights "$ROUTE53_HOSTED_ZONE_ID" 1 0
  else
    warn "ROUTE53_HOSTED_ZONE_ID not set — Route 53 restore skipped."
  fi

  # ── Step 4: Scale down GCP standby ───────────────────────────────────────
  info "Step 4: Scaling GCP Cloud Run back to pilot-light (0 min instances) ..."
  run gcloud run services update "$CLOUD_RUN_SERVICE" \
    --min-instances=0 \
    --max-instances=5 \
    --region="$GCP_REGION" \
    --project="$GCP_PROJECT_ID"

  info "Step 4b: Removing public invoker access from Cloud Run ..."
  run gcloud run services remove-iam-policy-binding "$CLOUD_RUN_SERVICE" \
    --region="$GCP_REGION" \
    --project="$GCP_PROJECT_ID" \
    --member="allUsers" \
    --role="roles/run.invoker"

  # ── Step 5: Verify failback ───────────────────────────────────────────────
  if [[ "$DRY_RUN" == "false" ]]; then
    info "Step 5: Waiting 30 s for DNS TTL propagation ..."
    sleep 30
    check_health "$PRIMARY_HEALTH_URL" "AWS Primary (post-failback)" \
      && info "✓ FAILBACK SUCCESSFUL — traffic is now served from AWS" \
      || warn "Health check still failing; verify ECS service and Route 53 TTL."
  fi

  info "═══════════════════════════════════════════════════════"
  info " Failback complete. Set cloud_run_public_access=false in"
  info " infrastructure/gcp and run terraform apply to persist."
  info "═══════════════════════════════════════════════════════"
}

# ── Entrypoint ────────────────────────────────────────────────────────────────
case "$DIRECTION" in
  aws-to-gcp)
    failover_aws_to_gcp
    ;;
  gcp-to-aws)
    failback_gcp_to_aws
    ;;
  *)
    die "Unknown direction '$DIRECTION'. Use --direction aws-to-gcp or gcp-to-aws"
    ;;
esac
