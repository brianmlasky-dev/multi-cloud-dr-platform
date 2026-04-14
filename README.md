# Multi-Cloud Disaster Recovery Platform

![AWS](https://img.shields.io/badge/AWS-Primary%20Cloud-232F3E?logo=amazonaws&logoColor=white)
![Google Cloud](https://img.shields.io/badge/Google%20Cloud-Standby%20Cloud-4285F4?logo=googlecloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-326CE5?logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containers-2496ED?logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?logo=githubactions&logoColor=white)
![Status](https://img.shields.io/badge/Status-Portfolio%20Project-success)

Production-grade multi-cloud disaster recovery solution designed to simulate high availability, automated failover, and operational resilience across AWS and Google Cloud.

## Demo Video

👉 [Watch the 60-second demo](https://www.loom.com/share/68cab57f64c5421f89fa36a75f00653f)

## Recruiter Quick Scan

**Role alignment:** Cloud Engineer, DevOps Engineer, Cloud Infrastructure Engineer, SRE-adjacent roles  
**Primary skills shown:** AWS, Google Cloud, Terraform, Kubernetes, Docker, GitHub Actions  
**Core scenario:** Multi-cloud disaster recovery for a compliance-sensitive payment platform  
**What this demonstrates:** Infrastructure as Code, failover planning, CI/CD, security validation, recovery objectives, operational discipline

## Architecture Overview

This project simulates a disaster recovery design where **AWS acts as the primary environment** and **GCP acts as the standby environment**. It was built to demonstrate how a cloud engineer can design for recovery, repeatability, and resilience rather than simply deploy infrastructure.

Key goals of the project:

- Design a multi-cloud disaster recovery pattern across AWS and GCP
- Provision infrastructure reproducibly with Terraform
- Deploy containerized workloads using Kubernetes and Docker
- Automate validation and security checks through GitHub Actions
- Document recovery targets, tradeoffs, and operational procedures

## Architecture Diagram

![Architecture Diagram](./docs/architecture-diagram.png)

High-level architecture showing the AWS primary environment, GCP standby environment, failover flow, CI/CD pipeline, and supporting recovery components.

## Business Scenario

A fictional payment-processing company requires a disaster recovery strategy for a customer-facing application handling sensitive transaction workflows. The system must remain available during platform or regional disruption while maintaining controlled recovery procedures, auditable infrastructure changes, and compliance-aware design choices.

## Recovery Objectives

- **RTO:** 5–15 minutes
- **RPO:** 15–60 minutes

These targets represent project design goals rather than production SLA commitments.

## Architecture Summary

- **Primary cloud:** AWS
- **Standby cloud:** Google Cloud
- **Provisioning:** Terraform
- **Containerization:** Docker
- **Orchestration:** Kubernetes
- **CI/CD:** GitHub Actions
- **Security scanning:** Trivy, tfsec, Checkov
- **Recovery model:** DNS-based failover and health-driven recovery workflow

## What This Project Demonstrates

### 1. Multi-Cloud Infrastructure as Code
Infrastructure is provisioned with Terraform to demonstrate repeatable, version-controlled resource management across AWS and GCP.

### 2. Disaster Recovery Design
The project is centered on recovery planning, including explicit RTO/RPO targets, failover thinking, and documented runbook procedures.

### 3. Modern Cloud Operations
Containerized workloads are packaged with Docker and deployed through Kubernetes-based environments to reflect current platform engineering practices.

### 4. CI/CD and Security Discipline
GitHub Actions automates validation and scanning, including infrastructure checks, policy review, and container security analysis.

### 5. Compliance-Aware Architecture
The business scenario is intentionally framed around a regulated environment so that reliability, documentation, change control, and security decisions remain central to the design.

## Architecture Decisions

### Why Multi-Cloud?
A multi-cloud design was chosen to demonstrate recovery planning beyond a single-provider failure domain. This increases resilience in the scenario, while also introducing real-world complexity that must be managed operationally.

### Why Terraform?
Terraform provides a consistent, version-controlled way to provision infrastructure across both AWS and GCP, making it a strong fit for a project focused on repeatability and controlled change.

### Why Kubernetes?
Kubernetes was selected to demonstrate workload portability, orchestration, and deployment consistency across environments, even though it adds operational overhead compared with simpler platform choices.

### Why GitHub Actions?
GitHub Actions keeps the CI/CD workflow visible, repository-centric, and easy for reviewers to inspect. It also supports fast feedback through automated validation and scanning.

## Tradeoffs and Design Decisions

| Decision | Why Chosen | Tradeoff |
|---|---|---|
| Multi-cloud primary/standby design | Demonstrates recovery planning beyond a single provider failure domain | Adds architectural and operational complexity |
| Terraform for provisioning | Enables repeatable, version-controlled infrastructure | Requires more up-front structure and provider configuration |
| Kubernetes for orchestration | Demonstrates portability and modern platform operations | Adds learning curve and operational overhead |
| GitHub Actions for CI/CD | Keeps automation transparent and tightly integrated with the repo | Less feature-rich than some enterprise CI/CD platforms |
| Compliance-sensitive payment scenario | Makes the architecture more realistic and business-driven | Raises the bar for documentation and justification |
| Documented RTO/RPO targets | Shows measurable recovery planning discipline | Targets remain design goals unless repeatedly validated through testing |

## Example Workflow

1. Define or update infrastructure in Terraform  
2. Commit changes to GitHub  
3. Run GitHub Actions validation and security checks  
4. Deploy or update workloads  
5. Validate application health and recovery readiness  
6. Simulate or document failover procedure

## Demo Walkthrough

This is the walkthrough I would use with a recruiter, hiring manager, or interviewer.

### 1. Deploy the Primary Environment
- Provision AWS infrastructure with Terraform
- Deploy the application and supporting services
- Confirm the application is healthy and reachable

### 2. Prepare the Standby Environment
- Provision the GCP standby environment with Terraform
- Validate that standby services are ready for recovery use
- Confirm sufficient alignment for controlled failover

### 3. Run CI/CD Validation
- Trigger GitHub Actions workflows on commit
- Run Terraform validation, security checks, and container scanning
- Review results before promotion

### 4. Verify Steady-State Health
- Confirm application health in AWS
- Review health endpoints, logs, and deployment readiness
- Validate that the runbook reflects the current system state

### 5. Simulate a Recovery Scenario
- Assume disruption in the AWS primary environment
- Follow the disaster recovery runbook
- Shift traffic and recovery operations to the GCP standby environment

### 6. Validate Recovery Outcome
- Confirm availability after failover
- Compare results against the documented RTO/RPO targets
- Record lessons learned and improvement opportunities

## Repository Structure

```text
.
├── .github/
│   └── workflows/
├── app/
├── docs/
│   ├── architecture-diagram.png
│   ├── architecture-diagram.drawio
│   └── disaster-recovery-runbook.md
├── infrastructure/
├── scripts/
├── .gitignore
└── README.md
