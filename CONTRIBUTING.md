# Contributing to Multi-Cloud DR Platform

## Branch Protection Rules

The `main` branch is protected with the following rules:

- **Require pull request reviews**: At least 1 approving review required before merging.
- **Require status checks to pass**: All CI workflows must pass:
  - `Validate AWS Terraform`
  - `Validate GCP Terraform`
  - `Trivy Security Scan`
  - `TFSec Terraform Security Scan`
  - `Checkov IaC Security Scan`
  - `Test Demo App`
  - `Build Docker Image`
- **Require branches to be up to date**: Branch must be up to date with `main` before merging.
- **No direct pushes**: All changes must go through a pull request — direct commits to `main` are blocked.
- **Require signed commits**: All commits must be GPG-signed.

## Development Workflow

1. Create a feature branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. Make your changes, commit, and push to the feature branch.
3. Open a pull request against `main`.
4. Ensure all CI checks pass and obtain the required review.
5. Merge via squash or merge commit — no force-pushes.

## Infrastructure Changes

- All Terraform changes must pass `terraform fmt`, `terraform init -backend=false`, and `terraform validate`.
- Security scans (Trivy, tfsec, Checkov) run automatically on every pull request.
- Test infrastructure changes locally with `terraform plan` before opening a PR.

## Application Changes

- The demo app CI runs on any change under `app/`.
- Docker images must build and pass the `/health` endpoint check.
- Update `app/requirements.txt` with pinned hashes when adding/upgrading Python dependencies.

## Secrets

Never commit credentials, API keys, or passwords. Use:
- **AWS**: Secrets Manager (referenced via ECS `secrets:` field)
- **GCP**: Secret Manager or environment-specific `.tfvars` files excluded via `.gitignore`
- **Terraform variables** marked `sensitive = true` for any secret inputs
