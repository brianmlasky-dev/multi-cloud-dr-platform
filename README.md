# Multi-Cloud Disaster Recovery Platform

![AWS](https://img.shields.io/badge/AWS-Primary%20Cloud-232F3E?logo=amazonaws&logoColor=white)
![Google Cloud](https://img.shields.io/badge/Google%20Cloud-Standby%20Cloud-4285F4?logo=googlecloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-326CE5?logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containers-2496ED?logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI/CD-2088FF?logo=githubactions&logoColor=white)

**Production-grade multi-cloud disaster recovery platform designed for automated failover, infrastructure consistency, and reliability engineering aligned to strict RTO/RPO objectives.**

---

## 🔥 Why This Project Matters

This project demonstrates how to design and operate a **resilient cloud platform**, not just deploy infrastructure.

It focuses on:
- Reliability engineering (RTO/RPO-driven design)  
- Automated failure detection and recovery  
- Infrastructure portability across cloud providers  
- Production-style system design tradeoffs (cost vs availability)  

---

## 🏗️ Architecture Overview

- **Primary Cloud:** AWS  
- **Standby Cloud:** Google Cloud Platform  
- **Orchestration:** Kubernetes  
- **Infrastructure Provisioning:** Terraform  
- **CI/CD:** GitHub Actions  

### Key Design Decisions

- Active-passive architecture aligned to business recovery objectives  
- Kubernetes ensures workload portability across cloud providers  
- Terraform enables consistent, repeatable infrastructure deployments  
- Health-check driven failover reduces downtime and manual intervention  

---

## 🧭 Architecture Diagram

![Architecture Diagram](./diagram.png)

---

## 🚀 Production Readiness Improvement: Failover Optimization

### 🧠 Problem

Initial failover time was approximately **2–3 minutes**, which is unacceptable for user-facing production systems.

---

### 🔍 Root Cause Analysis

Failover delay was caused by a combination of:

- **DNS TTL caching** delaying traffic redirection  
- **Health check detection latency (~90 seconds)**  
- **Cold standby environment startup time**  

---

### 🏗️ Architecture Evolution

**Before (Baseline Design)**  
