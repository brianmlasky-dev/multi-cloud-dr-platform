#!/usr/bin/env bats
# ─────────────────────────────────────────
# BATS tests for scripts/failover.sh
# Run with: bats scripts/tests/test_failover.bats
# ─────────────────────────────────────────

SCRIPT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/failover.sh"

# ── Helper: stub every external binary called by the script ─────────────────
setup() {
  # Create a temp bin directory and put it first on PATH so all stubs are used
  STUB_BIN="$(mktemp -d)"
  export PATH="$STUB_BIN:$PATH"

  # aws stub — captures arguments to LAST_AWS_ARGS
  cat > "$STUB_BIN/aws" <<'EOF'
#!/usr/bin/env bash
echo "aws $*" >&2
case "$*" in
  *list-health-checks*) echo "FAKEHCID" ;;
  *) true ;;
esac
EOF

  cat > "$STUB_BIN/gcloud" <<'EOF'
#!/usr/bin/env bash
echo "gcloud $*" >&2
true
EOF

  cat > "$STUB_BIN/curl" <<'EOF'
#!/usr/bin/env bash
# Simulate AWS primary unhealthy, GCP standby healthy
for arg in "$@"; do
  case "$arg" in
    *standby*) exit 0 ;;
  esac
done
# Default: primary is down
exit 1
EOF

  cat > "$STUB_BIN/dig" <<'EOF'
#!/usr/bin/env bash
echo "1.2.3.4"
EOF

  chmod +x "$STUB_BIN/aws" "$STUB_BIN/gcloud" "$STUB_BIN/curl" "$STUB_BIN/dig"
}

teardown() {
  rm -rf "$STUB_BIN"
}

# ── Tests ────────────────────────────────────────────────────────────────────

@test "failover.sh: --help / unknown arg exits non-zero" {
  run bash "$SCRIPT" --unknown-flag
  [ "$status" -ne 0 ]
  [[ "$output" =~ "Usage" ]]
}

@test "failover.sh: --dry-run aws-to-gcp prints DRY-RUN lines" {
  run bash "$SCRIPT" --dry-run --direction aws-to-gcp
  [ "$status" -eq 0 ]
  [[ "$output" =~ "DRY-RUN" ]]
}

@test "failover.sh: --dry-run gcp-to-aws prints DRY-RUN lines" {
  run bash "$SCRIPT" --dry-run --direction gcp-to-aws
  [ "$status" -eq 0 ]
  [[ "$output" =~ "DRY-RUN" ]]
}

@test "failover.sh: invalid direction exits non-zero" {
  run bash "$SCRIPT" --direction sideways
  [ "$status" -ne 0 ]
  [[ "$output" =~ "Unknown direction" ]]
}

@test "failover.sh: gcp-to-aws dry-run calls gcloud run services update" {
  run bash "$SCRIPT" --dry-run --direction gcp-to-aws
  [ "$status" -eq 0 ]
  [[ "$output" =~ "gcloud run services update" ]]
}

@test "failover.sh: gcp-to-aws dry-run calls gcloud run services remove-iam-policy-binding" {
  run bash "$SCRIPT" --dry-run --direction gcp-to-aws
  [ "$status" -eq 0 ]
  [[ "$output" =~ "remove-iam-policy-binding" ]]
}

@test "failover.sh: gcp-to-aws dry-run calls aws ecs describe-services" {
  run bash "$SCRIPT" --dry-run --direction gcp-to-aws
  [ "$status" -eq 0 ]
  [[ "$output" =~ "aws ecs describe-services" ]]
}

@test "failover.sh: aws-to-gcp dry-run calls gcloud sql instances patch" {
  run bash "$SCRIPT" --dry-run --direction aws-to-gcp
  [ "$status" -eq 0 ]
  [[ "$output" =~ "gcloud sql instances patch" ]]
}

@test "failover.sh: aws-to-gcp dry-run calls gcloud run services update" {
  run bash "$SCRIPT" --dry-run --direction aws-to-gcp
  [ "$status" -eq 0 ]
  [[ "$output" =~ "gcloud run services update" ]]
}

@test "failover.sh: respects GCP_PROJECT_ID env override" {
  export GCP_PROJECT_ID="my-test-project"
  run bash "$SCRIPT" --dry-run --direction gcp-to-aws
  [ "$status" -eq 0 ]
  [[ "$output" =~ "my-test-project" ]]
}

@test "failover.sh: respects AWS_REGION env override" {
  export AWS_REGION="eu-west-1"
  run bash "$SCRIPT" --dry-run --direction gcp-to-aws
  [ "$status" -eq 0 ]
  [[ "$output" =~ "eu-west-1" ]]
}
