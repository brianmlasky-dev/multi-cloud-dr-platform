# ─────────────────────────────────────────
# Crestline Financial DR Platform — Makefile
# ─────────────────────────────────────────

.PHONY: help test test-cov bats lint-tf smoke-local act-test up down

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "  test        Run Python unit tests"
	@echo "  test-cov    Run Python tests with coverage report"
	@echo "  bats        Run BATS shell-script tests"
	@echo "  lint-tf     Run terraform fmt -check on all modules"
	@echo "  smoke-local Start the app locally and hit /health"
	@echo "  act-test    Simulate the 'test-app' CI job locally using act"
	@echo "  up          Start local dev environment (docker compose)"
	@echo "  down        Stop local dev environment"

# ── Python tests ─────────────────────────────────────────────────────────────
test:
	cd app && python -m pytest tests/ -v

test-cov:
	cd app && python -m pytest tests/ -v \
		--cov=app \
		--cov-report=term-missing \
		--cov-report=xml:coverage.xml

# ── BATS shell tests ──────────────────────────────────────────────────────────
bats:
	bats scripts/tests/

# ── Terraform lint ────────────────────────────────────────────────────────────
lint-tf:
	terraform fmt -check -recursive infrastructure/

# ── Local smoke test ──────────────────────────────────────────────────────────
smoke-local:
	cd app && gunicorn --bind 0.0.0.0:8080 --workers 2 --timeout 60 app:app &
	sleep 5
	curl -sf http://localhost:8080/health | python3 -m json.tool
	pkill gunicorn || true

# ── act CI simulation ─────────────────────────────────────────────────────────
# Requires: brew install act  (or https://github.com/nektos/act)
act-test:
	act -j test-app --container-architecture linux/amd64

# ── Docker Compose ────────────────────────────────────────────────────────────
up:
	docker compose up

down:
	docker compose down -v
