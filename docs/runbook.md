# DR Runbook — Quick Reference

**Project:** Crestline Financial Multi-Cloud DR Platform  
**Author:** Brian M. Lasky  
**See also:** [Full disaster-recovery-runbook.md](./disaster-recovery-runbook.md)

---

## 1. Declare an Incident

Trigger an incident when **any** of the following is true:

| Signal | Threshold |
|--------|-----------|
| Route 53 health check | Failing ≥ 3 consecutive checks |
| CloudWatch `5xxRate` alarm | > 5 % for 5 minutes |
| ECS service task count | < 1 running for > 2 minutes |
| On-call page received | Immediately acknowledge |

---

## 2. Failover — AWS → GCP

```bash
# 1. Verify env vars are set (see .env.example)
source .env

# 2. Dry-run first — prints all actions without executing
./scripts/failover.sh --dry-run --direction aws-to-gcp

# 3. Execute failover
./scripts/failover.sh --direction aws-to-gcp
```

**What happens:**
1. Script verifies the AWS primary is unhealthy.
2. Cloud SQL is activated as primary.
3. Cloud Run is scaled to min=2 / max=10.
4. `allUsers` invoker IAM is granted on Cloud Run.
5. Route 53 health check failure threshold is tripped → DNS TTL elapses (60 s).
6. Script polls the GCP endpoint until healthy.

**Expected RTO:** 5–15 minutes.

---

## 3. Monitor During Failover

| Tool | What to watch |
|------|---------------|
| Route 53 → Health Checks | Status flips from `Healthy` → `Unhealthy` → GCP record active |
| CloudWatch → DR dashboard | ECS task count drops to 0 (expected) |
| GCP Monitoring | Cloud Run request count increases |
| `/status` endpoint | `active_cloud` changes from `AWS` → `GCP` |

```bash
# Poll the status endpoint every 10 seconds
watch -n10 curl -s https://app.crestlinefinancial.com/status | python3 -m json.tool
```

---

## 4. DB Sync Verification

```bash
# Check current sync lag
./scripts/sync-db.sh --status

# Expected output:
# HEALTHY  — lag < 15 min  (within RPO)
# WARNING  — lag 15–60 min (approaching RPO limit)
# CRITICAL — lag > 60 min  (RPO breached — escalate)
```

---

## 5. Failback — GCP → AWS

Once AWS is restored and validated:

```bash
# 1. Dry-run
./scripts/failover.sh --dry-run --direction gcp-to-aws

# 2. Run full sync to minimize data loss
./scripts/sync-db.sh gcp-to-aws

# 3. Execute failback
./scripts/failover.sh --direction gcp-to-aws
```

**What happens:**
1. ECS service health is verified.
2. DB is synced from Cloud SQL back to RDS.
3. Route 53 DNS is restored to the AWS ALB record.
4. Cloud Run is scaled back to pilot-light (min=0).
5. `allUsers` IAM on Cloud Run is revoked.

---

## 6. Escalation

| Severity | Action |
|----------|--------|
| P1 — active outage | Page on-call lead immediately |
| P2 — degraded | Notify team channel within 15 min |
| Post-incident | File RCA within 48 hours |

---

## 7. Secret Rotation

DB passwords rotate automatically every 30 days via the
`aws_secretsmanager_secret_rotation` Terraform resource
(`infrastructure/aws/secrets_rotation.tf`).

### Manual rotation trigger

```bash
# Force immediate rotation (e.g., after a suspected credential leak)
aws secretsmanager rotate-secret \
  --secret-id multi-cloud-dr/db-password \
  --region us-east-1
```

### Verify rotation status

```bash
aws secretsmanager describe-secret \
  --secret-id multi-cloud-dr/db-password \
  --region us-east-1 \
  --query "{LastRotated:LastRotatedDate,NextRotation:NextRotationDate,RotationEnabled:RotationEnabled}"
```

### After a rotation, restart ECS so tasks pick up the new secret

```bash
aws ecs update-service \
  --cluster multi-cloud-dr-cluster \
  --service multi-cloud-dr-service \
  --force-new-deployment \
  --region us-east-1
```

> **Note:** ECS Fargate fetches secrets at task launch time. The
> `aws_secretsmanager_secret_rotation` Lambda handles updating both the
> secret value and the RDS user password atomically, so no manual DB
> password change is required.
