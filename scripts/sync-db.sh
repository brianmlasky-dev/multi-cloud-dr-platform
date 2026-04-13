#!/usr/bin/env bash
# ─────────────────────────────────────────
# Crestline Financial — Database Sync Script
# Author: Brian M. Lasky
# Organization: Crestline Financial
#
# Usage:
#   ./sync-db.sh [--status]          Show sync lag and health
#   ./sync-db.sh aws-to-gcp          Dump AWS RDS → restore to Cloud SQL (standby sync)
#   ./sync-db.sh gcp-to-aws          Dump GCP Cloud SQL → restore to AWS RDS (failback)
#
# Environment variables required:
#   AWS_REGION            AWS region (default: us-east-1)
#   GCP_PROJECT_ID        GCP project ID (default: multi-cloud-dr-platform)
#   GCP_REGION            GCP region (default: us-central1)
#   RDS_HOST              RDS endpoint hostname
#   RDS_USER              RDS master username
#   RDS_PASSWORD          RDS master password
#   RDS_DB_NAME           RDS database name (default: crestline_db)
#   CLOUD_SQL_INSTANCE    Cloud SQL instance connection name (project:region:instance)
#   CLOUD_SQL_USER        Cloud SQL username
#   CLOUD_SQL_PASSWORD    Cloud SQL password
#   CLOUD_SQL_DB_NAME     Cloud SQL database name (default: crestline_db)
# ─────────────────────────────────────────
set -euo pipefail

# ── Defaults ─────────────────────────────────────────────────────────────────
AWS_REGION="${AWS_REGION:-us-east-1}"
GCP_PROJECT_ID="${GCP_PROJECT_ID:-multi-cloud-dr-platform}"
GCP_REGION="${GCP_REGION:-us-central1}"

PROJECT_NAME="multi-cloud-dr"
RDS_DB_NAME="${RDS_DB_NAME:-crestline_db}"
CLOUD_SQL_DB_NAME="${CLOUD_SQL_DB_NAME:-crestline_db}"
CLOUD_SQL_INSTANCE_NAME="${CLOUD_SQL_INSTANCE_NAME:-${PROJECT_NAME}-postgres}"

# S3 and GCS buckets used to stage dump files for cross-cloud transfers
S3_BUCKET="${S3_BUCKET:-${PROJECT_NAME}-app-storage}"
GCS_BUCKET="${GCS_BUCKET:-${PROJECT_NAME}-dr-storage}"
DUMP_PREFIX="db-sync"

# ── Helpers ───────────────────────────────────────────────────────────────────
log()  { echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] $*"; }
info() { log "INFO  $*"; }
warn() { log "WARN  $*"; }
die()  { log "ERROR $*"; exit 1; }

check_dependency() {
  command -v "$1" &>/dev/null || die "Required tool not found: $1. Please install it before running this script."
}

require_env() {
  [[ -n "${!1:-}" ]] || die "Required environment variable $1 is not set."
}

# ── Dependency checks ─────────────────────────────────────────────────────────
check_dependency pg_dump
check_dependency psql
check_dependency aws
check_dependency gcloud
check_dependency gsutil

# ════════════════════════════════════════════════════════════════════════════
# --status: Report sync lag and health
# ════════════════════════════════════════════════════════════════════════════
show_status() {
  info "Checking database sync status ..."

  # Retrieve last sync timestamp stored in S3 as a metadata object
  local last_sync_ts
  last_sync_ts=$(aws s3 cp "s3://${S3_BUCKET}/${DUMP_PREFIX}/last-sync.txt" - 2>/dev/null || echo "")

  if [[ -z "$last_sync_ts" ]]; then
    warn "No sync timestamp found in s3://${S3_BUCKET}/${DUMP_PREFIX}/last-sync.txt"
    warn "Run './sync-db.sh aws-to-gcp' to perform the first sync."
    echo ""
    echo "Last sync: UNKNOWN"
    echo "Lag:       UNKNOWN"
    echo "Status:    UNKNOWN"
    return 0
  fi

  local now_epoch last_epoch lag_seconds lag_minutes lag_display status
  now_epoch=$(date -u +%s)
  last_epoch=$(date -u -d "$last_sync_ts" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "$last_sync_ts" +%s 2>/dev/null || echo 0)
  lag_seconds=$(( now_epoch - last_epoch ))
  lag_minutes=$(( lag_seconds / 60 ))
  lag_display="${lag_minutes} minutes $(( lag_seconds % 60 )) seconds"

  if   [[ $lag_minutes -lt 15  ]]; then status="HEALTHY";  fi
  if   [[ $lag_minutes -ge 15 && $lag_minutes -lt 60 ]]; then status="WARNING";  fi
  if   [[ $lag_minutes -ge 60 ]]; then status="CRITICAL"; fi

  echo ""
  echo "Last sync: $last_sync_ts"
  echo "Lag:       $lag_display"
  echo "Status:    $status"
  echo ""

  case "$status" in
    HEALTHY)  info "✓ Sync lag is within acceptable RPO (< 15 min). Safe to proceed with failover." ;;
    WARNING)  warn "⚠ Sync lag is 15-60 min. Notify team and assess data loss risk before failover." ;;
    CRITICAL) warn "✗ Sync lag exceeds 60 min. Investigate sync failure before proceeding." ;;
  esac
}

# ════════════════════════════════════════════════════════════════════════════
# AWS RDS → GCP Cloud SQL  (normal standby sync / scheduled job)
# ════════════════════════════════════════════════════════════════════════════
sync_aws_to_gcp() {
  info "═══════════════════════════════════════════════════════"
  info " DB SYNC: AWS RDS → GCP Cloud SQL"
  info "═══════════════════════════════════════════════════════"

  require_env RDS_HOST
  require_env RDS_USER
  require_env RDS_PASSWORD
  require_env CLOUD_SQL_USER
  require_env CLOUD_SQL_PASSWORD

  local dump_file timestamp s3_key gcs_key proxy_pid proxy_sock
  timestamp=$(date -u '+%Y%m%d-%H%M%S')
  dump_file="/tmp/${DUMP_PREFIX}-${timestamp}.pgdump"
  s3_key="${DUMP_PREFIX}/latest.pgdump"
  gcs_key="${DUMP_PREFIX}/latest.pgdump"
  proxy_sock="/tmp/cloudsql-${timestamp}"

  # ── Step 1: Dump from RDS ──────────────────────────────────────────────────
  info "Step 1: Dumping RDS database '${RDS_DB_NAME}' from ${RDS_HOST} ..."
  PGPASSWORD="$RDS_PASSWORD" pg_dump \
    --host="$RDS_HOST" \
    --port=5432 \
    --username="$RDS_USER" \
    --dbname="$RDS_DB_NAME" \
    --format=custom \
    --no-acl \
    --no-owner \
    --file="$dump_file"
  info "Dump written to $dump_file"

  # ── Step 2: Upload dump to S3 (staging) ───────────────────────────────────
  info "Step 2: Uploading dump to s3://${S3_BUCKET}/${s3_key} ..."
  aws s3 cp "$dump_file" "s3://${S3_BUCKET}/${s3_key}" \
    --region "$AWS_REGION" \
    --sse AES256
  info "Dump staged in S3."

  # ── Step 3: Copy dump from S3 to GCS via signed URL ───────────────────────
  info "Step 3: Transferring dump to gs://${GCS_BUCKET}/${gcs_key} ..."
  local signed_url
  signed_url=$(aws s3 presign "s3://${S3_BUCKET}/${s3_key}" \
    --region "$AWS_REGION" \
    --expires-in 3600)

  gsutil cp "$signed_url" "gs://${GCS_BUCKET}/${gcs_key}"
  info "Dump available in GCS."

  # ── Step 4: Restore into Cloud SQL via Cloud SQL Auth Proxy ───────────────
  info "Step 4: Restoring dump into Cloud SQL '${CLOUD_SQL_INSTANCE_NAME}' ..."

  # Download the dump from GCS locally for restore
  local local_restore_file="/tmp/${DUMP_PREFIX}-restore-${timestamp}.pgdump"
  gsutil cp "gs://${GCS_BUCKET}/${gcs_key}" "$local_restore_file"

  # Start Cloud SQL Auth Proxy
  info "Starting Cloud SQL Auth Proxy ..."
  cloud-sql-proxy \
    "${GCP_PROJECT_ID}:${GCP_REGION}:${CLOUD_SQL_INSTANCE_NAME}" \
    --unix-socket="$proxy_sock" \
    --quiet &
  proxy_pid=$!
  sleep 5

  PGPASSWORD="$CLOUD_SQL_PASSWORD" pg_restore \
    --host="$proxy_sock" \
    --username="$CLOUD_SQL_USER" \
    --dbname="$CLOUD_SQL_DB_NAME" \
    --format=custom \
    --clean \
    --if-exists \
    --no-acl \
    --no-owner \
    "$local_restore_file" || {
      kill "$proxy_pid" 2>/dev/null || true
      die "pg_restore failed — check Cloud SQL connectivity and credentials."
    }

  kill "$proxy_pid" 2>/dev/null || true
  info "Restore complete."

  # ── Step 5: Record sync timestamp ─────────────────────────────────────────
  info "Step 5: Recording sync timestamp ..."
  local sync_ts
  sync_ts=$(date -u '+%Y-%m-%d %H:%M:%S')
  echo "$sync_ts" | aws s3 cp - "s3://${S3_BUCKET}/${DUMP_PREFIX}/last-sync.txt" \
    --region "$AWS_REGION" \
    --sse AES256 \
    --content-type "text/plain"

  # ── Step 6: Cleanup ───────────────────────────────────────────────────────
  rm -f "$dump_file" "$local_restore_file"

  info "═══════════════════════════════════════════════════════"
  info " ✓ Sync complete at $sync_ts"
  info "═══════════════════════════════════════════════════════"
}

# ════════════════════════════════════════════════════════════════════════════
# GCP Cloud SQL → AWS RDS  (failback data repatriation)
# ════════════════════════════════════════════════════════════════════════════
sync_gcp_to_aws() {
  info "═══════════════════════════════════════════════════════"
  info " DB SYNC: GCP Cloud SQL → AWS RDS (failback)"
  info "═══════════════════════════════════════════════════════"

  require_env RDS_HOST
  require_env RDS_USER
  require_env RDS_PASSWORD
  require_env CLOUD_SQL_USER
  require_env CLOUD_SQL_PASSWORD

  local dump_file timestamp gcs_key s3_key proxy_pid proxy_sock
  timestamp=$(date -u '+%Y%m%d-%H%M%S')
  dump_file="/tmp/${DUMP_PREFIX}-gcp-${timestamp}.pgdump"
  gcs_key="${DUMP_PREFIX}/failback-${timestamp}.pgdump"
  s3_key="${DUMP_PREFIX}/failback-${timestamp}.pgdump"
  proxy_sock="/tmp/cloudsql-failback-${timestamp}"

  # ── Step 1: Dump from Cloud SQL via Auth Proxy ────────────────────────────
  info "Step 1: Dumping Cloud SQL '${CLOUD_SQL_INSTANCE_NAME}' ..."
  cloud-sql-proxy \
    "${GCP_PROJECT_ID}:${GCP_REGION}:${CLOUD_SQL_INSTANCE_NAME}" \
    --unix-socket="$proxy_sock" \
    --quiet &
  proxy_pid=$!
  sleep 5

  PGPASSWORD="$CLOUD_SQL_PASSWORD" pg_dump \
    --host="$proxy_sock" \
    --username="$CLOUD_SQL_USER" \
    --dbname="$CLOUD_SQL_DB_NAME" \
    --format=custom \
    --no-acl \
    --no-owner \
    --file="$dump_file" || {
      kill "$proxy_pid" 2>/dev/null || true
      die "pg_dump from Cloud SQL failed — check connectivity and credentials."
    }

  kill "$proxy_pid" 2>/dev/null || true
  info "Dump written to $dump_file"

  # ── Step 2: Upload dump to GCS (staging) ─────────────────────────────────
  info "Step 2: Uploading dump to gs://${GCS_BUCKET}/${gcs_key} ..."
  gsutil cp "$dump_file" "gs://${GCS_BUCKET}/${gcs_key}"

  # ── Step 3: Download dump to local (for S3 upload / direct restore) ───────
  info "Step 3: Uploading dump to s3://${S3_BUCKET}/${s3_key} ..."
  aws s3 cp "$dump_file" "s3://${S3_BUCKET}/${s3_key}" \
    --region "$AWS_REGION" \
    --sse AES256

  # ── Step 4: Restore into RDS ──────────────────────────────────────────────
  info "Step 4: Restoring dump into RDS '${RDS_DB_NAME}' at ${RDS_HOST} ..."
  PGPASSWORD="$RDS_PASSWORD" pg_restore \
    --host="$RDS_HOST" \
    --port=5432 \
    --username="$RDS_USER" \
    --dbname="$RDS_DB_NAME" \
    --format=custom \
    --clean \
    --if-exists \
    --no-acl \
    --no-owner \
    "$dump_file" || die "pg_restore into RDS failed — check RDS connectivity and credentials."
  info "Restore complete."

  # ── Step 5: Record sync timestamp ─────────────────────────────────────────
  info "Step 5: Recording sync timestamp ..."
  local sync_ts
  sync_ts=$(date -u '+%Y-%m-%d %H:%M:%S')
  echo "$sync_ts" | aws s3 cp - "s3://${S3_BUCKET}/${DUMP_PREFIX}/last-sync.txt" \
    --region "$AWS_REGION" \
    --sse AES256 \
    --content-type "text/plain"

  # ── Step 6: Cleanup ───────────────────────────────────────────────────────
  rm -f "$dump_file"

  info "═══════════════════════════════════════════════════════"
  info " ✓ Failback sync complete at $sync_ts"
  info "═══════════════════════════════════════════════════════"
}

# ── Entrypoint ────────────────────────────────────────────────────────────────
COMMAND="${1:-}"

case "$COMMAND" in
  --status)
    show_status
    ;;
  aws-to-gcp|"")
    sync_aws_to_gcp
    ;;
  gcp-to-aws)
    sync_gcp_to_aws
    ;;
  *)
    die "Unknown command '$COMMAND'. Usage: $0 [--status | aws-to-gcp | gcp-to-aws]"
    ;;
esac
