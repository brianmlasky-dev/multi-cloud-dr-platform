content = open("scripts/write-runbook.py").read()

runbook = """# 🚨 Disaster Recovery Runbook
**Project:** Multi-Cloud DR Platform  
**Author:** Brian M. Lasky  
**Organization:** Northstar Commerce  
**Last Updated:** April 2026  
**Version:** 1.0

---

## 📋 Table of Contents
1. [Overview](#overview)
2. [RTO & RPO Targets](#rto--rpo-targets)
3. [Architecture Summary](#architecture-summary)
4. [Incident Severity Levels](#incident-severity-levels)
5. [Failover Procedure](#failover-procedure)
6. [Failback Procedure](#failback-procedure)
7. [Database Sync Verification](#database-sync-verification)
8. [Health Check Monitoring](#health-check-monitoring)
9. [Contact & Escalation](#contact--escalation)

---

## 1. Overview

This runbook documents the procedures for detecting, responding to, and
recovering from a disaster affecting the primary AWS infrastructure.
The standby environment on GCP (us-central1) is continuously synced
and can be activated within the RTO window.

---

## 2. RTO & RPO Targets

| Metric | Target | Description |
|--------|--------|-------------|
| **RTO** | 5-15 minutes | Time to restore service after failure |
| **RPO** | 15-60 minutes | Maximum acceptable data loss window |
| **MTTR** | < 30 minutes | Mean time to recovery |
| **Availability** | 99.95% | Annual uptime target |

---

## 3. Architecture Summary

| Layer | Primary (AWS) | Standby (GCP) |
|-------|--------------|---------------|
| Compute | ECS Fargate (us-east-1) | Cloud Run (us-central1) |
| Database | RDS PostgreSQL | Cloud SQL PostgreSQL |
| Storage | S3 Bucket | GCS Bucket |
| DNS | Route 53 Failover | Route 53 Failover |
| Monitoring | CloudWatch | GCP Monitoring |

---

## 4. Incident Severity Levels

| Level | Description | Response Time | Action |
|-------|-------------|---------------|--------|
| **P1** | Full AWS region outage | Immediate | Execute full failover |
| **P2** | Partial service degradation | < 5 min | Investigate + partial failover |
| **P3** | Performance degradation | < 15 min | Monitor + scale |
| **P4** | Non-critical component failure | < 1 hour | Schedule maintenance |

---

## 5. Failover Procedure

### Prerequisites
- [ ] Confirm AWS primary region is unreachable
- [ ] Verify GCP standby environment is healthy
- [ ] Notify stakeholders via incident channel
- [ ] Confirm latest DB sync timestamp

### Step 1: Verify the Outage

    # Check AWS health
    curl -f https://app.northstarcommerce.com/health || echo "PRIMARY DOWN"

    # Check GCP standby health
    curl -f https://standby.northstarcommerce.com/health || echo "STANDBY DOWN"

### Step 2: Promote GCP Cloud SQL to Primary

    gcloud sql instances patch northstar-dr-postgres \\
      --activation-policy=ALWAYS \\
      --project=northstar-dr-platform

### Step 3: Scale Up Cloud Run

    gcloud run services update northstar-dr-app \\
      --min-instances=2 \\
      --max-instances=10 \\
      --region=us-central1

### Step 4: Update Route 53 DNS Failover

    aws route53 change-resource-record-sets \\
      --hosted-zone-id YOUR_ZONE_ID \\
      --change-batch file://failover-dns.json

### Step 5: Verify Failover

    dig app.northstarcommerce.com
    curl -f https://app.northstarcommerce.com/health && echo "FAILOVER SUCCESS"

---

## 6. Failback Procedure

### Step 1: Verify AWS Environment Health

    aws ecs describe-services \\
      --cluster northstar-dr-cluster \\
      --services northstar-dr-service \\
      --region us-east-1

### Step 2: Sync Data Back to AWS RDS

    ./scripts/sync-db.sh gcp-to-aws

### Step 3: Restore Route 53 to Primary

    aws route53 change-resource-record-sets \\
      --hosted-zone-id YOUR_ZONE_ID \\
      --change-batch file://failback-dns.json

### Step 4: Scale Down GCP Standby

    gcloud run services update northstar-dr-app \\
      --min-instances=0 \\
      --max-instances=5 \\
      --region=us-central1

### Step 5: Verify Failback

    curl -f https://app.northstarcommerce.com/health && echo "FAILBACK SUCCESS"

---

## 7. Database Sync Verification

Run this before any failover to confirm data freshness:

    ./scripts/sync-db.sh --status

    # Expected output:
    # Last sync: 2026-04-13 14:32:01 UTC
    # Lag: 4 minutes 12 seconds
    # Status: HEALTHY

### Sync Lag Thresholds

| Lag | Status | Action |
|-----|--------|--------|
| < 15 min | HEALTHY | Proceed with failover |
| 15-60 min | WARNING | Notify team, assess data loss risk |
| > 60 min | CRITICAL | Investigate sync failure before failover |

---

## 8. Health Check Monitoring

| Check | Endpoint | Interval | Threshold |
|-------|----------|----------|-----------|
| AWS Primary | /health | 30 sec | 3 failures |
| GCP Standby | /health | 30 sec | 3 failures |
| RDS | Port 5432 | 60 sec | 2 failures |
| Cloud SQL | Port 5432 | 60 sec | 2 failures |

---

## 9. Contact & Escalation

| Role | Name | Action |
|------|------|--------|
| **DR Lead** | Brian M. Lasky | Execute runbook |
| **AWS Support** | AWS Console | Open P1 ticket |
| **GCP Support** | GCP Console | Open P1 ticket |

---

*This runbook should be reviewed and tested quarterly.*  
*Last DR drill: April 2026*
"""

with open("docs/disaster-recovery-runbook.md", "w") as f:
    f.write(runbook)

print("Runbook written successfully!")
