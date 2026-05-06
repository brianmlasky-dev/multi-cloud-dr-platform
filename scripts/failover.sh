#!/usr/bin/env bash
set -euo pipefail

HEALTH_CHECK_ID="${HEALTH_CHECK_ID:-REPLACE_WITH_TERRAFORM_OUTPUT}"
GCP_CLOUDRUN_URL="${GCP_CLOUDRUN_URL:-https://northstar-app-placeholder.run.app}"
AWS_REGION="${AWS_REGION:-us-east-1}"
POLL_INTERVAL=5
POLL_TIMEOUT=120
LOG_FILE="/tmp/northstar-failover-$(date +%Y%m%d-%H%M%S).log"

log() { echo "$(date +%Y-%m-%dT%H:%M:%S) [$1] $2" | tee -a "$LOG_FILE"; }

preflight_checks() {
  log INFO "Running preflight checks..."
  if [[ "${SIMULATE:-false}" == "true" ]]; then
    log INFO "SIMULATE mode - skipping credential checks"
    DRY_RUN=true
    log INFO "Preflight passed (dry_run=${DRY_RUN})"
    return
  fi
  if ! command -v aws &>/dev/null; then log ERROR "AWS CLI not found"; exit 1; fi
  if ! aws sts get-caller-identity --region "$AWS_REGION" &>/dev/null; then
    log ERROR "AWS credentials not configured"; exit 1
  fi
  if [[ "$HEALTH_CHECK_ID" == "REPLACE_WITH_TERRAFORM_OUTPUT" ]]; then
    log WARN "HEALTH_CHECK_ID not set - DRY RUN mode"
    DRY_RUN=true
  else
    DRY_RUN=false
  fi
  log INFO "Preflight passed (dry_run=${DRY_RUN})"
}

disable_primary_health_check() {
  log WARN "Disabling primary health check -> triggering DNS cutover to GCP"
  if [[ "$DRY_RUN" == "true" ]]; then
    log WARN "DRY RUN: would disable health check ${HEALTH_CHECK_ID}"
    return
  fi
  aws route53 update-health-check \
    --health-check-id "$HEALTH_CHECK_ID" \
    --inverted --region "$AWS_REGION" > /dev/null
  log INFO "Health check inverted - Route 53 failover triggered"
}

poll_gcp_health() {
  log INFO "Polling GCP: ${GCP_CLOUDRUN_URL}/health"
  if [[ "${SIMULATE:-false}" == "true" ]]; then
    log INFO "SIMULATE mode - GCP endpoint returning HTTP 200"
    log INFO "GCP healthy (HTTP 200) after 0s"
    echo "0"; return 0
  fi
  local elapsed=0 http_status
  while [[ $elapsed -lt $POLL_TIMEOUT ]]; do
    http_status=$(curl -s -o /dev/null -w "%{http_code}" \
      --max-time 10 "${GCP_CLOUDRUN_URL}/health" 2>/dev/null || echo "000")
    if [[ "$http_status" == "200" ]]; then
      log INFO "GCP healthy (HTTP 200) after ${elapsed}s"
      echo "$elapsed"; return 0
    fi
    log INFO "GCP not ready (HTTP ${http_status}) - ${elapsed}s elapsed"
    sleep "$POLL_INTERVAL"
    elapsed=$((elapsed + POLL_INTERVAL))
  done
  log ERROR "GCP did not become healthy within ${POLL_TIMEOUT}s"
  echo "$POLL_TIMEOUT"; return 1
}

restore_primary() {
  log INFO "Restoring primary health check..."
  if [[ "$DRY_RUN" == "true" ]]; then
    log WARN "DRY RUN: would restore ${HEALTH_CHECK_ID}"; return
  fi
  aws route53 update-health-check \
    --health-check-id "$HEALTH_CHECK_ID" \
    --no-inverted --region "$AWS_REGION" > /dev/null
  log INFO "Primary restored"
}

print_rto_summary() {
  echo "========================================================"
  echo "  FAILOVER COMPLETE - RTO METRICS"
  echo "  Start time  : $2"
  echo "  GCP healthy : $3"
  echo "  RTO achieved: ${1}s  (target: <60s)"
  if [[ $1 -lt 60 ]]; then echo "  Target met  : YES"
  else echo "  Target met  : NO - check GCP cold start"; fi
  echo "  Log         : ${LOG_FILE}"
  echo "========================================================"
}

main() {
  local mode="${1:---auto}"
  log INFO "NorthStar Commerce DR Failover starting"
  preflight_checks
  case "$mode" in
    --restore)
      restore_primary; exit 0 ;;
    --simulate|--auto)
      local start_time start_epoch
      start_time=$(date +%Y-%m-%dT%H:%M:%S)
      start_epoch=$(date +%s)
      log WARN "FAILOVER INITIATED: AWS -> GCP"
      disable_primary_health_check
      if [[ "${SIMULATE:-false}" != "true" ]]; then
        log INFO "Waiting 30s for DNS TTL..."
        sleep 30
      else
        log INFO "SIMULATE mode - skipping DNS TTL wait"
      fi
      poll_gcp_health
      local total_rto=$(( $(date +%s) - start_epoch ))
      print_rto_summary "$total_rto" "$start_time" "$(date +%Y-%m-%dT%H:%M:%S)"
      ;;
    *)
      echo "Usage: $0 [--simulate|--restore|--auto]"; exit 1 ;;
  esac
}

main "${1:---auto}"
