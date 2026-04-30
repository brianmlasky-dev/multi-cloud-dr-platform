# Multi-Cloud Disaster Recovery Platform
![AWS](https://img.shields.io/badge/AWS-Cloud-orange)
![GCP](https://img.shields.io/badge/GCP-Cloud-blue)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-blue)
![Status](https://img.shields.io/badge/Status-Portfolio_Project-green)

Production-style multi-cloud disaster recovery system designed for high availability, fault tolerance, and rapid failover across AWS and Google Cloud.

## 🚀 Overview

This project simulates a compliance-sensitive payment platform requiring strict uptime and recovery guarantees. It demonstrates how to design and implement a reliable, cost-effective disaster recovery strategy using an active-passive architecture.

- **Primary:** AWS  
- **Standby:** Google Cloud (GCP)  
- **Failover Strategy:** Health-based DNS routing  
- **Failover Time:** **< 60 seconds (optimized)**  

---

## 🎯 Objectives

- Achieve **RTO: 5–15 minutes**
- Achieve **RPO: 15–60 minutes**
- Minimize downtime during regional/cloud failures
- Balance reliability, cost, and operational complexity

---

## 🏗️ Architecture

![Architecture Diagram](docs/architecture-diagram.png)

### Key Components

- **Terraform** → Infrastructure provisioning across AWS and GCP  
- **Kubernetes** → Container orchestration for workload portability  
- **Docker** → Application containerization  
- **GitHub Actions** → CI/CD automation and validation  
- **Health Checks + DNS Routing** → Automated failover decision-making  

---

## ⚙️ How Failover Works

1. AWS (primary) is continuously monitored via health checks  
2. If thresholds are breached:
   - High latency
   - Increased error rate
   - Resource exhaustion
3. Traffic is redirected to GCP (standby)  
4. Kubernetes workloads scale to handle traffic  
5. System stabilizes in standby environment  

---

## ⚡ Optimization Highlights

- Reduced DNS TTL from **300s → 30s** to minimize cached failures  
- Tightened health check intervals (**30s → 10s**)  
- Improved failure detection logic  
- Reduced failover time from ~3 minutes → **sub-60 seconds**  

---

## 📊 Observability (In Progress)

Planned improvements:
- Centralized logging
- Metrics aggregation
- Alerting system
- Automated failover validation

---

## 🧪 Testing & Simulation

The platform includes endpoints to simulate and validate system behavior:

- `/health` → Current system health  
- `/status` → Active environment  
- `/metrics` → Runtime metrics  
- `/failover` → Simulated failover trigger  

---

## 🛠️ Tech Stack

- AWS  
- Google Cloud (GCP)  
- Terraform  
- Kubernetes  
- Docker  
- GitHub Actions  

---

## ⚖️ Design Trade-offs

| Approach        | Pros                          | Cons                              |
|----------------|-------------------------------|-----------------------------------|
| Active-Passive | Lower cost, simpler design    | Slightly slower failover          |
| Active-Active  | Faster failover               | Higher cost, operational complexity |

This project intentionally uses **active-passive** to balance cost and reliability while still meeting defined RTO/RPO targets.

---

## 🔮 Future Improvements

- Global load balancing (latency-based routing)  
- Enhanced observability stack  
- Automated chaos testing  
- Security hardening and compliance checks  

---

## 💡 Key Takeaways

- Designed for failure, not just uptime  
- Prioritized **reliability over complexity**  
- Focused on **real-world constraints and trade-offs**  
- Demonstrates **SRE principles in practice**  

---

## 👤 Author

Brian Lasky  
Cloud / DevOps Engineer → Site Reliability Engineering (SRE)  

---

## 📎 Repository Structure
