# NorthStar Commerce — Multi-Cloud Disaster Recovery Platform

[![Terraform](https://img.shields.io/badge/Terraform-1.7-purple?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-ECS%20%7C%20RDS%20%7C%20Route53-orange?logo=amazonaws)](https://aws.amazon.com/)
[![GCP](https://img.shields.io/badge/GCP-Cloud%20Run%20%7C%20Cloud%20SQL-blue?logo=googlecloud)](https://cloud.google.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15.4-blue?logo=postgresql)](https://www.postgresql.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

> **Production-grade multi-cloud disaster recovery platform** demonstrating automated failover
> from AWS (primary) to GCP (secondary) with validated RTO < 60 seconds and RPO < 5 minutes.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [DR Metrics](#dr-metrics)
- [Tech Stack](#tech-stack)
- [Repository Structure](#repository-structure)
- [Failover Sequence](#failover-sequence)
- [Database Sync](#database-sync)
- [DR Runbook](#dr-runbook)
- [Cost Profile](#cost-profile)
- [Build Log](#build-log)

---

## Architecture Overview

┌─────────────────────────────────────────────────────────────────┐ │ NORMAL OPERATIONS │ │ │ │ Users → Route 53 (Primary) → AWS ECS (Fargate) │ │ │ │ │ ALB (us-east-1) │ │ │ │ │ RDS PostgreSQL 15.4 │ │ (Multi-AZ Primary) │ │ │ │ │ RDS Read Replica │ │ (Cross-AZ Standby) │ └─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐ │ FAILOVER STATE │ │ │ │ Users → Route 53 (Failover) → GCP Cloud Run │ │ │ │ │ Cloud SQL PostgreSQL │ │ (Restored from GCS) │ │ │ │ │ sync-db.sh: RDS → S3 → GCS (every 5 min) │ │ │ │ │ failover.sh: DNS cutover < 60 seconds │ └─────────────────────────────────────────────────────────────────┘


**Component Summary**

| Layer | AWS (Primary) | GCP (Secondary) |
|-------|---------------|-----------------|
| Compute | ECS Fargate | Cloud Run |
| Database | RDS PostgreSQL 15.4 Multi-AZ | Cloud SQL (restored from GCS) |
| DNS | Route 53 Health Check + Failover | Route 53 Failover Target |
| Storage | S3 (state + DB snapshots) | GCS (cross-cloud DB replica) |
| IaC State | S3 + DynamoDB locking | — |
| Secrets | AWS Secrets Manager | GCP Secret Manager |

---

## DR Metrics

| Metric | Target | Validated |
|--------|--------|-----------|
| RTO (Recovery Time Objective) | < 60 seconds | ✅ `failover.sh` timestamp logging |
| RPO (Recovery Point Objective) | < 5 minutes | ✅ `sync-db.sh` interval tracking |
| DNS Propagation | < 30 seconds | ✅ Route 53 TTL = 30s |
| DB Snapshot Frequency | Every 5 minutes | ✅ Cron-ready sync script |
| State Lock Contention | 0 conflicts | ✅ DynamoDB locking |

> Metrics derived from operational scripts. RTO logged in `logs/failover.log`.
> RPO tracked in `logs/sync.log` with elapsed-time validation against 300s threshold.

---

## Tech Stack

| Category | Technology |
|----------|------------|
| Infrastructure as Code | Terraform 1.7 |
| Primary Cloud | AWS (ECS Fargate, RDS, Route 53, S3, ALB) |
| Secondary Cloud | GCP (Cloud Run, Cloud SQL, GCS) |
| Database | PostgreSQL 15.4 |
| Container Runtime | Docker |
| DNS Failover | Route 53 Health Checks + Failover Routing |
| State Management | S3 Remote Backend + DynamoDB Locking |
| DB Replication | pg_dump → S3 (SSE-AES256) → gsutil cross-cloud |
| Scripting | Bash (failover.sh, sync-db.sh) |
| Application | Python 3.11 / Flask |

---

## Repository Structure

multi-cloud-dr-platform/ ├── infrastructure/ │ ├── aws/ │ │ ├── backend.tf # S3 remote state + DynamoDB locking │ │ ├── main.tf # ECS Fargate, ALB, security groups │ │ ├── rds.tf # PostgreSQL 15.4 Multi-AZ + read replica │ │ ├── vpc.tf # VPC, subnets, route tables │ │ └── variables.tf │ └── gcp/ │ ├── cloudrun.tf # Secondary compute target │ └── variables.tf ├── scripts/ │ ├── failover.sh # DNS cutover with RTO logging (RTO < 60s) │ └── sync-db.sh # pg_dump → S3 → GCS replication (RPO < 5m) ├── app/ │ └── app.py # Flask health + status endpoints ├── logs/ │ ├── failover.log # RTO timestamps │ └── sync.log # RPO elapsed-time records └── README.md

---

## Failover Sequence

When Route 53 health checks detect AWS primary failure:

Route 53 health check fails (TTL: 30s detection window)
failover.sh triggered — records start timestamp
DNS record updated: ECS ALB → GCP Cloud Run endpoint
Health check confirms GCP endpoint responding
RTO timestamp logged to logs/failover.log
Total elapsed time validated against 60s threshold


**Manual failover trigger:**
```bash
chmod +x scripts/failover.sh
./scripts/failover.sh

---

## Database Sync

`scripts/sync-db.sh` runs on a 5-minute cron interval to maintain RPO < 5 minutes.

---

## Database Sync

`scripts/sync-db.sh` runs on a 5-minute cron interval to maintain RPO < 5 minutes.

RDS PostgreSQL 15.4 │ ▼ pg_dump (compressed) │ ▼ S3 Bucket (SSE-AES256 encryption) s3://northstar-dr-backups/db-snapshots/ │ ▼ gsutil cross-cloud replication │ ▼ GCS Bucket gs://northstar-dr-backups/db-snapshots/ │ ▼ Cloud SQL restore-ready on failover


**Manual sync trigger:**
```bash
chmod +x scripts/sync-db.sh
./scripts/sync-db.sh
