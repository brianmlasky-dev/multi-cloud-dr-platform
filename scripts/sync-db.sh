#!/usr/bin/env bash
# =============================================================================
# sync-db.sh — NorthStar Commerce DR Platform
# Purpose : pg_dump RDS -> S3 -> GCS cross-cloud replication
# RPO Target : < 5 minutes
# Author  : Brian Lasky | Agentic Platform Engineer Portfolio
# =============================================================================
set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-northstar}"
DB_USER="${DB_USER:-northstar_user}"
PGPASSWORD="${PGPASSWORD:-}"

S3_BUCKET="${S3_BUCKET:-northstar-dr-backups}"
S3_PREFIX="${S3_PREFIX:-db-backups}"
AWS_REGION="${AWS_REGION:-us-east-1}"

GCS_BUCKET="${GCS_BUCKET:-northstar-dr-backups-gcp}"
GCS_PREFIX="${GCS_PREFIX:-db-backups}"

BACKUP_DIR="${BACKUP_DIR:-/tmp/northstar-backups}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
LOG_FILE="/tmp/northstar-sync-$(date +%Y%m%d).log"

# ── Logging ──────────────────────────────────────────────────────────────────
log() { echo "$(date +%Y-%m-%dT%H:%M:%S) [$1] $2" | tee -a "$LOG_FILE"; }

# ── Preflight ────────────────────────────────────────────────────────────────
preflight() {
  log INFO "Running preflight checks..."
  local missing=()

  command -v pg_dump  &>/dev/null || missing+=("pg_dump")
  command -v aws      &>/dev/null || missing+=("aws-cli")
  command -v gsutil   &>/dev/null || missing+=("gsutil")
  command -v gzip     &>/dev/null || missing+=("gzip")

  if [[ ${#missing[@]} -gt 0 ]]; then
    log WARN "Missing tools (simulation mode): ${missing[*]}"
    SIMULATE=true
  else
    SIMULATE=false
  fi

  mkdir -p "$BACKUP_DIR"
  log INFO "Preflight complete (simulate=${SIMULATE})"
}

# ── Step 1: pg_dump ──────────────────────────────────────────────────────────
dump_database() {
  local timestamp
  timestamp=$(date +%Y%m%d-%H%M%S)
  DUMP_FILE="${BACKUP_DIR}/northstar-${timestamp}.sql.gz"
  RPO_START=$(date +%s)

  log INFO "Starting pg_dump: ${DB_HOST}:${DB_PORT}/${DB_NAME}"

  if [[ "$SIMULATE" == "true" ]]; then
    log WARN "SIMULATE: creating dummy dump file"
    echo "-- NorthStar DR simulated dump $(date)" | gzip > "$DUMP_FILE" 2>/dev/null \
      || echo "-- simulated" > "${DUMP_FILE%.gz}" && DUMP_FILE="${DUMP_FILE%.gz}"
  else
    export PGPASSWORD
    pg_dump \
      --host="$DB_HOST" \
      --port="$DB_PORT" \
      --username="$DB_USER" \
      --dbname="$DB_NAME" \
      --format=plain \
      --no-password \
      | gzip > "$DUMP_FILE"
  fi

  local size
  size=$([ -f "$DUMP_FILE" ] && du -sh "$DUMP_FILE" | cut -f1 || echo "simulated")
  log INFO "Dump complete: ${DUMP_FILE} (${size})"
}

# ── Step 2: Upload to S3 ─────────────────────────────────────────────────────
upload_to_s3() {
  local s3_path="s3://${S3_BUCKET}/${S3_PREFIX}/$(basename "$DUMP_FILE")"
  log INFO "Uploading to S3: ${s3_path}"

  if [[ "$SIMULATE" == "true" ]]; then
    log WARN "SIMULATE: would run -> aws s3 cp ${DUMP_FILE} ${s3_path}"
    S3_URI="$s3_path"
    return 0
  fi

  aws s3 cp "$DUMP_FILE" "$s3_path" \
    --region "$AWS_REGION" \
    --sse AES256 \
    --storage-class STANDARD_IA

  S3_URI="$s3_path"
  log INFO "S3 upload complete: ${S3_URI}"
}

# ── Step 3: Replicate to GCS ─────────────────────────────────────────────────
replicate_to_gcs() {
  local gcs_path="gs://${GCS_BUCKET}/${GCS_PREFIX}/$(basename "$DUMP_FILE")"
  log INFO "Replicating to GCS: ${gcs_path}"

  if [[ "$SIMULATE" == "true" ]]; then
    log WARN "SIMULATE: would run -> gsutil cp ${DUMP_FILE} ${gcs_path}"
    GCS_URI="$gcs_path"
    return 0
  fi

  gsutil -q cp "$DUMP_FILE" "$gcs_path"
  GCS_URI="$gcs_path"
  log INFO "GCS replication complete: ${GCS_URI}"
}

# ── Step 4: Cleanup old local backups ────────────────────────────────────────
cleanup_local() {
  log INFO "Removing local backups older than ${RETENTION_DAYS} days"
  find "$BACKUP_DIR" -name "northstar-*.sql*" \
    -mtime +"$RETENTION_DAYS" -delete 2>/dev/null || true
  log INFO "Cleanup complete"
}

# ── Step 5: RPO Metric ───────────────────────────────────────────────────────
print_rpo_summary() {
  local rpo_elapsed=$(( $(date +%s) - RPO_START ))
  echo "========================================================"
  echo "  SYNC COMPLETE - RPO METRICS"
  echo "  Timestamp   : $(date +%Y-%m-%dT%H:%M:%S)"
  echo "  Dump file   : $(basename "$DUMP_FILE")"
  echo "  S3 URI      : ${S3_URI:-N/A}"
  echo "  GCS URI     : ${GCS_URI:-N/A}"
  echo "  Elapsed     : ${rpo_elapsed}s  (target: <300s)"
  if [[ $rpo_elapsed -lt 300 ]]; then
    echo "  RPO Target  : MET ✓"
  else
    echo "  RPO Target  : MISSED - investigate network/DB latency"
  fi
  echo "  Log         : ${LOG_FILE}"
  echo "========================================================"
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
  log INFO "NorthStar Commerce DB Sync starting"
  preflight
  dump_database
  upload_to_s3
  replicate_to_gcs
  cleanup_local
  print_rpo_summary
  log INFO "Sync job complete"
}

main "$@"
