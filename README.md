# Multi-Cloud Disaster Recovery Platform

![AWS](https://img.shields.io/badge/AWS-Primary%20Cloud-232F3E?logo=amazonaws&logoColor=white)
![Google Cloud](https://img.shields.io/badge/Google%20Cloud-Standby%20Cloud-4285F4?logo=googlecloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-326CE5?logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containers-2496ED?logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI/CD-2088FF?logo=githubactions&logoColor=white)

**Production-style multi-cloud platform simulating automated failover, infrastructure as code, and observability aligned to enterprise RTO/RPO objectives.**

---

## 🔥 Why This Project Matters

This project demonstrates how to design and operate a **cloud platform**, not just deploy infrastructure.

It focuses on:
- Reliability engineering (RTO/RPO-driven design)  
- Automation-first infrastructure  
- Platform reusability across environments  
- Failure detection and recovery  

---

## 🏗️ Architecture Overview

- **Primary Cloud:** AWS  
- **Standby Cloud:** Google Cloud Platform  
- **Orchestration:** Kubernetes  
- **Infrastructure Provisioning:** Terraform  
- **CI/CD:** GitHub Actions  

### Key Design Decisions:
- Active-passive failover model aligned to recovery objectives  
- Kubernetes for workload portability across cloud providers  
- Infrastructure as Code for repeatable deployments  
- Health-check driven failover to minimize downtime  

---

## 🧭 Architecture Diagram

![Architecture Diagram](./diagram.png)

---

## 📊 System Health Monitoring

![Health Check](./screenshots/health-check.png)

Real-time health endpoint used to determine failover conditions between cloud environments.

---

## 🔁 Failover Simulation

![Failover](./screenshots/failover.png)

Automated failover triggered when primary environment health thresholds are not met.

---

## ⚙️ CI/CD Pipeline

![CI/CD](./screenshots/pipeline.png)

Automated infrastructure provisioning and deployment using GitHub Actions.

---

## 🧱 Infrastructure as Code

![Terraform](./screenshots/terraform.png)

Infrastructure provisioned using modular Terraform configurations for repeatable deployments.

---

## ⚙️ Platform Engineering Focus

This project is built with a platform mindset:

- Infrastructure is modular and reusable  
- Workloads are environment-agnostic  
- Deployment is fully automated  
- Systems are designed for failure first  

---

## 🔁 Failover Strategy

- Continuous health checks monitor the AWS primary environment  
- Failover is triggered when health thresholds are not met  
- Traffic is redirected to the GCP standby environment  
- Recovery aligns with defined RTO/RPO targets  

---

## 📊 Observability & Monitoring

- Health checks simulate production monitoring systems  
- Logging and metrics are designed to:
  - Detect failure conditions early  
  - Reduce false positives  
  - Enable automated recovery decisions  

---

## 🔧 CI/CD & Automation

- GitHub Actions pipelines handle:
  - Infrastructure provisioning  
  - Deployment validation  
  - Continuous updates  

- Focus on:
  - Reducing manual intervention  
  - Ensuring consistency across environments  

---

## 🧠 Key Engineering Principles

- Design for failure, not success  
- Automate everything possible  
- Standardize infrastructure patterns  
- Minimize operational overhead  
- Build systems for other engineers to consume  

---

## 🧪 Failure Simulation Guide

This platform includes a simple mechanism to simulate failure and trigger automated failover.

### Step 1: Trigger Failure
Modify the health check endpoint to return an unhealthy status:
