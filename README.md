![Status](https://img.shields.io/badge/status-in_progress-yellow)
![AWS Certified Solutions Architect – Associate](https://img.shields.io/badge/AWS%20SAA-Certified-yellow?logo=amazon-aws)
![Google Professional Cloud Architect](https://img.shields.io/badge/GCP%20PCA-Certified-blue?logo=google-cloud)

# Multi-Cloud Disaster Recovery Platform for Mission-Critical Transactions

**Author:** Brian M. Lasky  
**Aspirational Role:** Cloud Solutions Architect  
**LinkedIn:** [linkedin.com/in/brian-lasky-67464086](https://www.linkedin.com/in/brian-lasky-67464086/)  
**GitHub:** [github.com/brianmlasky-dev](https://github.com/brianmlasky-dev)

---

## Executive Summary

A portfolio demo for a fictional mid-market retailer, showcasing a resilient, cost-conscious architecture that protects revenue by **failing over from AWS to Google Cloud** in the event of regional outages.

---

## Table of Contents
- [Business Context](#business-context)
- [Architecture Overview](#architecture-overview)
- [Why These Technologies?](#why-these-technologies)
- [RTO and RPO Goals](#rto-and-rpo-goals)
- [Disaster Scenario Walkthrough](#disaster-scenario-walkthrough)
- [Tradeoffs and Future Improvements](#tradeoffs-and-future-improvements)
- [Cost Considerations](#cost-considerations)
- [How to Run / Get Started](#how-to-run--get-started)
- [About Me](#about-me)
- [Screenshots & Diagrams](#screenshots--diagrams)
- [Runbook](#runbook)

---

## Business Context

**Northstar Commerce** needs around-the-clock uptime for its customer transaction system. A seasonal outage could mean lost sales, customer churn, and big headaches for auditors.

> 💡 **Cloud Architect Confidence Tip:**  
> Always tie the project to a business problem: "Why does this exist?"  
> This immediately sets you apart from folks who do tech-for-tech’s-sake.

---

## Architecture Overview

**Primary Environment:**  
- AWS ECS Fargate (frontend & backend)
- AWS RDS (PostgreSQL)
- S3 (object storage)
- Route 53 (DNS failover/health checks)

**Secondary Environment:**  
- GCP Cloud Run (standby app)
- Cloud SQL for PostgreSQL
- GCS (backups)
- GCP Monitoring

**Failover:**  
Route 53 DNS detects outages and sends traffic to the GCP standby stack.  
Database is synced using scheduled logical export/import; some recent writes may be lost (see RPO discussion).

---

## Why These Technologies?

- **ECS Fargate & Cloud Run:** Low ops, familiar to most cloud orgs.
- **PostgreSQL:** Cross-cloud, mature, easy to backup.
- **Route 53:** Visual health/failover, easy to demo.
- **Terraform:** Reproducible infra, resume-worthy skill.
- **Scheduled logical backup:** Honest about RPO tradeoffs, achievable for portfolios.

> **Cloud Architect Confidence Tip:**  
> When you talk about technology, always mention _"why"_—business value, reliability, cost, or speed.

---

## RTO and RPO Goals

- **RTO (Recovery Time Objective):** 5–15 min
- **RPO (Recovery Point Objective):** 15–60 min

_This means we aim to restore service and minimize lost transactions as quickly as makes sense for a business of this size._

---

## Disaster Scenario Walkthrough

1. **All systems healthy:** AWS handles all traffic.
2. **Simulated outage:** Route 53 detects downtime (backend or AWS region).
3. **Failover:** DNS swings traffic to GCP; Cloud Run handles new requests.
4. **Data Recovery:** GCP DB is restored/imported from last backup/export.
5. **Restore primary:** Runbook used to restore AWS stack and swing traffic back.

---

## Tradeoffs and Future Improvements

- **Active-passive:** Cheaper, easy to explain, but slightly higher RPO/RTO.
- **Scheduled sync:** Simple, but not true real-time. Could add CDC for lower RPO.
- **Monitoring:** Both clouds; may want unified dashboard in the future.

---

## Cost Considerations

- Idle standby on GCP saves cost.
- Pay-per-use models on Cloud Run/simple RDS sizing.
- Minimal storage for backups.

> **Cloud Architect Confidence Tip:**  
> Always mention how cost/complexity tradeoffs are balanced—shows you think like an owner.

---

## How to Run / Get Started

_Coming soon!_  
Step-by-step deployment, local dev, and demo instructions coming as the project is built.

---

## About Me

Hi, I’m Brian—a passionate future Cloud Solutions Architect (GCP PCA & AWS SAA certified), focused on marrying technical excellence with business resiliency.  
I created this project to showcase my ability to design real-world, resilient cloud systems that balance cost, operational simplicity, and business continuity.

---

## Screenshots & Diagrams

![Architecture Diagram](docs/architecture-diagram.png)

---

## Runbook

See [`docs/disaster-recovery-runbook.md`](docs/disaster-recovery-runbook.md) for step-by-step recovery and failover actions.
