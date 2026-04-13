#!/usr/bin/env bats
# ─────────────────────────────────────────
# BATS tests for scripts/sync-db.sh
# Run with: bats scripts/tests/test_sync_db.bats
# ─────────────────────────────────────────

SCRIPT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/sync-db.sh"

setup() {
  STUB_BIN="$(mktemp -d)"
  export PATH="$STUB_BIN:$PATH"

  # Stub all external dependencies required by the script
  for cmd in pg_dump psql aws gcloud gsutil "cloud-sql-proxy" pg_restore; do
    cat > "$STUB_BIN/$cmd" <<EOF
#!/usr/bin/env bash
echo "$cmd \$*" >&2
true
EOF
    chmod +x "$STUB_BIN/$cmd"
  done

  # Make the aws stub return a fake timestamp for --status
  cat > "$STUB_BIN/aws" <<'EOF'
#!/usr/bin/env bash
echo "aws $*" >&2
case "$*" in
  *s3\ cp*last-sync.txt*-)
    # Simulate reading the timestamp from S3
    echo "2099-01-01 00:00:00"
    ;;
  *s3\ cp*)
    true
    ;;
  *s3\ presign*)
    echo "https://fake-presigned-url.example.com/dump.pgdump"
    ;;
  *)
    true
    ;;
esac
EOF
  chmod +x "$STUB_BIN/aws"

  # Set required env vars
  export RDS_HOST=fake-rds.example.com
  export RDS_USER=testuser
  export RDS_PASSWORD=testpass
  export CLOUD_SQL_USER=cloudsqluser
  export CLOUD_SQL_PASSWORD=cloudsqlpass
  export AWS_REGION=us-east-1
  export GCP_PROJECT_ID=test-project
  export GCP_REGION=us-central1
}

teardown() {
  rm -rf "$STUB_BIN"
}

# ── Tests ────────────────────────────────────────────────────────────────────

@test "sync-db.sh: --status exits 0 when S3 returns a timestamp" {
  run bash "$SCRIPT" --status
  [ "$status" -eq 0 ]
}

@test "sync-db.sh: --status prints Last sync and Lag lines" {
  run bash "$SCRIPT" --status
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Last sync" ]]
  [[ "$output" =~ "Lag" ]]
}

@test "sync-db.sh: --status reports HEALTHY for a future timestamp" {
  run bash "$SCRIPT" --status
  [ "$status" -eq 0 ]
  [[ "$output" =~ "HEALTHY" ]]
}

@test "sync-db.sh: aws-to-gcp calls pg_dump" {
  run bash "$SCRIPT" aws-to-gcp
  [ "$status" -eq 0 ]
  [[ "$output" =~ "pg_dump" ]]
}

@test "sync-db.sh: aws-to-gcp calls aws s3 cp to upload dump" {
  run bash "$SCRIPT" aws-to-gcp
  [ "$status" -eq 0 ]
  [[ "$output" =~ "aws s3 cp" ]]
}

@test "sync-db.sh: aws-to-gcp calls gsutil cp" {
  run bash "$SCRIPT" aws-to-gcp
  [ "$status" -eq 0 ]
  [[ "$output" =~ "gsutil cp" ]]
}

@test "sync-db.sh: aws-to-gcp calls pg_restore" {
  run bash "$SCRIPT" aws-to-gcp
  [ "$status" -eq 0 ]
  [[ "$output" =~ "pg_restore" ]]
}

@test "sync-db.sh: gcp-to-aws calls pg_dump from Cloud SQL" {
  run bash "$SCRIPT" gcp-to-aws
  [ "$status" -eq 0 ]
  [[ "$output" =~ "pg_dump" ]]
}

@test "sync-db.sh: gcp-to-aws calls pg_restore into RDS" {
  run bash "$SCRIPT" gcp-to-aws
  [ "$status" -eq 0 ]
  [[ "$output" =~ "pg_restore" ]]
}

@test "sync-db.sh: unknown command exits non-zero" {
  run bash "$SCRIPT" invalid-command
  [ "$status" -ne 0 ]
  [[ "$output" =~ "Unknown command" ]]
}

@test "sync-db.sh: aws-to-gcp fails without RDS_HOST" {
  unset RDS_HOST
  run bash "$SCRIPT" aws-to-gcp
  [ "$status" -ne 0 ]
  [[ "$output" =~ "RDS_HOST" ]]
}

@test "sync-db.sh: gcp-to-aws records sync timestamp in S3" {
  run bash "$SCRIPT" gcp-to-aws
  [ "$status" -eq 0 ]
  [[ "$output" =~ "last-sync.txt" ]]
}
