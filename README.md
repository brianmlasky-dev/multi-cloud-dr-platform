# 🏦 Crestline Financial — Multi-Cloud Disaster Recovery Platform

![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![GCP](https://img.shields.io/badge/GCP-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![PCI-DSS](https://img.shields.io/badge/PCI--DSS-Compliant-green?style=for-the-badge)
![SOC2](https://img.shields.io/badge/SOC2-Compliant-green?style=for-the-badge)

[![Demo App CI](https://github.com/brianmlasky-dev/multi-cloud-dr-platform/actions/workflows/demo-app.yml/badge.svg)](https://github.com/brianmlasky-dev/multi-cloud-dr-platform/actions/workflows/demo-app.yml)
[![Terraform Validate](https://github.com/brianmlasky-dev/multi-cloud-dr-platform/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/brianmlasky-dev/multi-cloud-dr-platform/actions/workflows/terraform-validate.yml)
[![Security Scan](https://github.com/brianmlasky-dev/multi-cloud-dr-platform/actions/workflows/security-scan.yml/badge.svg)](https://github.com/brianmlasky-dev/multi-cloud-dr-platform/actions/workflows/security-scan.yml)
[![codecov](https://codecov.io/gh/brianmlasky-dev/multi-cloud-dr-platform/branch/main/graph/badge.svg)](https://codecov.io/gh/brianmlasky-dev/multi-cloud-dr-platform)

> **Designed and built by Brian M. Lasky**
> Enterprise-grade multi-cloud disaster recovery platform for Crestline Financial —
> a real-time payment processing company serving mid-market retailers and regional banks.
> Automated failover between AWS (Primary) and GCP (Standby) with a target RTO of 5-15 minutes
> and RPO of 15-60 minutes, meeting PCI-DSS and SOC 2 compliance requirements.

---

## Overview

Crestline Financial processes **$2.4B in annual payment transactions** for over 800 mid-market
retailers and 12 regional banks across North America. A single hour of downtime costs an
estimated **$1.2M in lost transactions** and risks regulatory penalties under PCI-DSS.

This platform provides:

- **Infrastructure as Code** - 100% Terraform, no ClickOps, fully auditable
- **Multi-Cloud Architecture** - AWS primary + GCP standby, no single cloud dependency
- **Automated Failover** - Route 53 health checks trigger DNS failover in minutes
- **Container Orchestration** - Kubernetes on EKS and GKE with autoscaling
- **CI/CD Automation** - GitHub Actions validates and scans every commit
- **Compliance Controls** - PCI-DSS, SOC 2, and audit logging built in from day one
- **Live REST API** - Simulates real DR operations and platform health monitoring

## Key Metrics

| Metric | Target | Regulatory Requirement |
|--------|--------|----------------------|
| RTO (Recovery Time Objective) | 5-15 minutes | PCI-DSS: < 4 hours |
| RPO (Recovery Point Objective) | 15-60 minutes | PCI-DSS: < 24 hours |
| Availability Target | 99.95% | SOC 2 Type II |
| Transaction Data Encryption | AES-256 | PCI-DSS Req. 3.5 |
| Audit Log Retention | 12 months | PCI-DSS Req. 10.7 |

---

## Business Context

### The Problem
Crestline Financial's legacy single-cloud AWS deployment had three critical vulnerabilities:

1. AWS us-east-1 outage took Crestline offline for 3.5 hours costing $4.2M in lost transactions
2. PCI-DSS audit identified single-cloud deployment as high risk requiring remediation within 90 days
3. Manual failover process took 6+ hours, far exceeding the 4-hour RTO regulatory requirement

### The Solution
- Multi-cloud active/standby eliminates single cloud dependency
- Automated DNS failover achieves 5-15 minute RTO
- PCI-DSS and SOC 2 controls built into infrastructure from day one
- All infrastructure versioned, auditable, and reproducible via Terraform

---

## Tech Stack

### Cloud Infrastructure
| Provider | Role | Services |
|----------|------|---------|
| **AWS** | Primary | VPC, ECS Fargate, RDS PostgreSQL Multi-AZ, S3, Route 53, CloudWatch, CloudTrail, GuardDuty |
| **GCP** | Standby | Cloud Run, Cloud SQL PostgreSQL, GCS, Cloud Monitoring, Cloud Armor, IAM, Audit Logs |

### DevOps and Automation
| Tool | Purpose |
|------|---------|
| **Terraform** | IaC for all cloud resources on both AWS and GCP |
| **Kubernetes** | Container orchestration on EKS and GKE |
| **Docker** | Application containerization with non-root security |
| **GitHub Actions** | CI/CD - validate, scan, and test on every commit |
| **Trivy** | Container and filesystem CVE scanning |
| **TFSec** | Terraform security misconfiguration scanning |
| **Checkov** | IaC compliance policy enforcement |

### Application
| Tool | Purpose |
|------|---------|
| **Python 3.11** | Payment platform demo API |
| **Flask 3.0** | Lightweight REST framework |
| **Gunicorn** | Production-grade WSGI server |

---

## Live Demo API

### Run Locally

    git clone https://github.com/brianmlasky-dev/multi-cloud-dr-platform.git
    cd multi-cloud-dr-platform/app
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    gunicorn --bind 0.0.0.0:8080 --workers 2 --timeout 60 app:app

### Run with Docker Compose (app + Postgres)

    git clone https://github.com/brianmlasky-dev/multi-cloud-dr-platform.git
    cd multi-cloud-dr-platform
    docker compose up

### Common Make Targets

| Target | Description |
|--------|-------------|
| `make test` | Run Python unit tests |
| `make test-cov` | Run tests with coverage report |
| `make bats` | Run BATS shell-script tests |
| `make lint-tf` | Check Terraform formatting |
| `make act-test` | Simulate CI locally with `act` |
| `make up` | Start local dev environment |

### API Endpoints

| Endpoint | Description |
|----------|-------------|
| /health | Platform health check |
| /status | Full payment platform status |
| /failover | DR failover simulation |
| /metrics | Live transaction metrics |

---

## Disaster Recovery

### Strategy: Pilot Light
- AWS runs full production workload at all times
- GCP runs minimal standby infrastructure scaled to zero
- On failover GCP scales up automatically to handle full traffic

### RTO/RPO Achievement
- RTO Target: 5-15 minutes (PCI-DSS requires < 4 hours) — achieved via `scripts/failover.sh` automated failover
- RPO Target: 15-60 minutes (PCI-DSS requires < 24 hours) — enforced by `scripts/sync-db.sh` scheduled every 15 minutes via GitHub Actions (`sync-db.yml`)

### DR Operations

    # Check current DB sync lag and health
    ./scripts/sync-db.sh --status

    # Automated failover: AWS → GCP (with dry-run support)
    ./scripts/failover.sh --dry-run
    ./scripts/failover.sh --direction aws-to-gcp

    # Failback: GCP → AWS
    ./scripts/failover.sh --direction gcp-to-aws

---

## Compliance and Security

| Control | Implementation |
|---------|----------------|
| IAM least privilege | Scoped roles on both clouds |
| Encryption at rest | AES-256 on all storage and databases |
| Audit logging | CloudTrail (AWS) + Cloud Audit Logs (GCP) |
| Threat detection | AWS GuardDuty enabled |
| WAF / DDoS protection | AWS WAF v2 (ALB) + GCP Cloud Armor |
| IaC security scanning | TFSec + Checkov on every commit |
| Vulnerability scanning | Trivy on every commit |
| Non-root containers | Dockerfile uses unprivileged user |

---

## Author

**Brian M. Lasky**
Aspiring Cloud and DevOps Engineer

Built to demonstrate enterprise-grade cloud engineering skills for financial services infrastructure roles.

GitHub: https://github.com/brianmlasky-dev/multi-cloud-dr-platform
