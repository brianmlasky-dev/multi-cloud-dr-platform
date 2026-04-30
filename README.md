# 🌐 Multi-Cloud Disaster Recovery Platform

![AWS](https://img.shields.io/badge/AWS-Cloud-orange)
![GCP](https://img.shields.io/badge/GCP-Cloud-blue)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-blue)
![Status](https://img.shields.io/badge/Status-Portfolio_Project-green)

**AWS (Primary) → Google Cloud (Failover) | Terraform • Kubernetes • Docker • GitHub Actions**

---

## 🚨 Overview

Designed and implemented a **multi-cloud disaster recovery platform** simulating a compliance-sensitive payment system with automated failover.

* ⏱️ **Failover Time:** < 60 seconds (optimized)
* 📉 **RTO:** 5–15 minutes
* 💾 **RPO:** 15–60 minutes
* ⚙️ **Architecture:** Active-Passive (cost-optimized, production-aligned)

---

## 🧠 Why This Matters

Most systems fail not because of lack of infrastructure—but because of poor failover design and slow detection.

This project demonstrates:

* Designing for **business continuity (RTO/RPO)**
* Balancing **cost vs reliability vs complexity**
* Building systems that **fail predictably and recover automatically**

---

## 🏗️ Architecture

![Architecture Diagram](docs/architecture-diagram.png)

### Key Components

* **Terraform** → Multi-cloud infrastructure provisioning
* **Kubernetes** → Workload portability across clouds
* **Docker** → Containerized application runtime
* **GitHub Actions** → CI/CD validation and automation
* **Health Checks + DNS Routing** → Automated failover

---

## ⚙️ How Failover Works

1. AWS (primary) is continuously monitored
2. Health thresholds trigger failure conditions:

   * High latency
   * Increased error rate
   * Resource exhaustion
3. DNS routing redirects traffic to GCP
4. Kubernetes scales workloads in standby
5. System stabilizes in the failover environment

---

## ⚡ Optimization Highlights

* Reduced DNS TTL from **300s → 30s**
* Tightened health checks (**30s → 10s**)
* Improved failure detection logic
* Reduced failover time from ~3 minutes → **<60 seconds**

---

## 🧪 Failure Scenarios Tested

| Scenario        | Detection           | Outcome            |
| --------------- | ------------------- | ------------------ |
| AWS outage      | ~20–30s             | Failover to GCP    |
| High latency    | Threshold triggered | Traffic redirected |
| Degraded health | Health checks fail  | Recovery initiated |

---

## 🔍 Reliability & Incident Analysis

* Root cause analysis (RCA) performed on simulated failures
* Identified **detection latency** as primary bottleneck
* Optimized DNS TTL and health check intervals
* Result: Failover reduced from ~3 minutes → **<60 seconds**

---

## 📊 Observability

Endpoints available:

* `/health` → system health
* `/status` → active cloud environment
* `/metrics` → runtime metrics
* `/failover` → simulated failover trigger

Example:

```
requests_total 3
failovers_total 1
last_decision{decision="FAILOVER"} 1
```

---

## 🛠️ Tech Stack

* AWS
* Google Cloud (GCP)
* Terraform
* Kubernetes
* Docker
* GitHub Actions

---

## ⚖️ Design Trade-offs

| Approach       | Pros                       | Cons                                |
| -------------- | -------------------------- | ----------------------------------- |
| Active-Passive | Lower cost, simpler design | Slightly slower failover            |
| Active-Active  | Faster failover            | Higher cost, operational complexity |

This project intentionally uses **active-passive** to balance cost, reliability, and operational complexity while meeting defined RTO/RPO targets.

---

## 🔮 Future Improvements

* Centralized observability (Grafana / Datadog)
* Automated failover validation testing
* Global load balancing (latency-based routing)
* Security and compliance enhancements

---

## 💡 Key Takeaways

* Designed for failure, not just uptime
* Built around **business SLAs (RTO/RPO)**
* Focused on **real-world tradeoffs**
* Demonstrates **SRE principles in practice**

---

## 👤 Author

Brian Lasky
Cloud / DevOps Engineer → Site Reliability Engineering (SRE)

---

## 📁 Repository Structure

```
infrastructure/
  aws/
  gcp/
  kubernetes/
docs/
app/
.github/workflows/
```
