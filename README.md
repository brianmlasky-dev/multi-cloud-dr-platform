# Multi-Cloud Disaster Recovery Platform

![AWS](https://img.shields.io/badge/AWS-Primary%20Cloud-232F3E?logo=amazonaws&logoColor=white)
![Google Cloud](https://img.shields.io/badge/Google%20Cloud-Standby%20Cloud-4285F4?logo=googlecloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-326CE5?logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containers-2496ED?logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI%2FCD-2088FF?logo=githubactions&logoColor=white)
![Status](https://img.shields.io/badge/Status-Portfolio%20Project-success)

Production-style multi-cloud disaster recovery platform designed to demonstrate high availability, automated failover, and operational resilience across AWS and Google Cloud.

## Demo Video

👉 [Watch the 60-second demo](https://www.loom.com/share/68cab57f64c5421f89fa36a75f00653f)

## Recruiter Quick Scan

**Role alignment:** Cloud Engineer, DevOps Engineer, Cloud Infrastructure Engineer, SRE-adjacent roles  
**Primary skills shown:** AWS, Google Cloud, Terraform, Kubernetes, Docker, GitHub Actions  
**Core scenario:** Multi-cloud disaster recovery for a compliance-sensitive payment platform  
**What this demonstrates:** Infrastructure as Code, failover planning, CI/CD, security validation, recovery objectives, and operational discipline

## Architecture Overview

This project simulates a multi-cloud disaster recovery design in which **AWS serves as the primary environment** and **Google Cloud serves as the standby environment**. It was built to demonstrate how cloud infrastructure can be designed for recovery, repeatability, and resilience—not just deployment.

Key goals of the project:

- Design a disaster recovery pattern across AWS and Google Cloud
- Provision infrastructure reproducibly with Terraform
- Deploy containerized workloads using Docker and Kubernetes
- Automate validation and security checks through GitHub Actions
- Document recovery objectives, architectural tradeoffs, and operational procedures

## Architecture Diagram

![Architecture Diagram](./docs/architecture-diagram.png)

High-level architecture showing the AWS primary environment, Google Cloud standby environment, failover flow, CI/CD pipeline, and supporting recovery components.

## Key Files

- [`docs/architecture-diagram.png`](./docs/architecture-diagram.png) — high-level architecture diagram
- [`docs/disaster-recovery-runbook.md`](./docs/disaster-recovery-runbook.md) — disaster recovery procedure and operational steps
- [`infrastructure/`](./infrastructure/) — infrastructure as code and cloud resource definitions
- [`.github/workflows/`](./.github/workflows/) — CI/CD automation and validation workflows
- [`app/`](./app/) — demo application source code

  ## Demo Endpoints

The demo application exposes endpoints that simulate normal operations and failover-related behavior:

- `/health` — application health status
- `/status` — platform and environment status
- `/metrics` — example runtime metrics
- `/failover` — simulated recovery behavior

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

## Technical Capabilities Demonstrated

### 1. Multi-Cloud Infrastructure as Code
Infrastructure is provisioned with Terraform to demonstrate repeatable, version-controlled resource management across AWS and Google Cloud.

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
Terraform provides a consistent, version-controlled way to provision infrastructure across both AWS and Google Cloud, making it a strong fit for a project focused on repeatability and controlled change.

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

## Outcome

This project demonstrates the ability to design and document a resilient multi-cloud recovery architecture with clear operational objectives, repeatable infrastructure provisioning, and visible CI/CD and security controls. It reflects the kind of technical decision-making expected in Cloud, DevOps, and infrastructure-focused engineering roles.

## Example Workflow

1. Define or update infrastructure in Terraform  
2. Commit changes to GitHub  
3. Trigger GitHub Actions validation and security checks  
4. Deploy or update application workloads  
5. Validate application health and recovery readiness  
6. Simulate or document failover procedures

## Demo Walkthrough

This is the walkthrough I would use to explain the project to a recruiter, hiring manager, or interviewer in a concise, business-relevant way.

### 1. Deploy the Primary Environment
- Provision the AWS primary environment with Terraform
- Deploy the application and supporting services
- Confirm that the application is healthy and reachable

### 2. Prepare the Standby Environment
- Provision the Google Cloud standby environment with Terraform
- Validate that standby services are configured and ready for recovery use
- Confirm sufficient alignment between environments to support controlled failover

### 3. Run CI/CD Validation
- Trigger GitHub Actions workflows on commit
- Run Terraform validation, security checks, and container scanning
- Review pipeline results before promoting changes

### 4. Verify Steady-State Health
- Confirm application health in the AWS environment
- Review health endpoints, logs, and deployment readiness
- Validate that the disaster recovery runbook reflects the current system state

### 5. Simulate a Recovery Scenario
- Assume a disruption in the AWS primary environment
- Follow the disaster recovery runbook
- Shift traffic and recovery operations to the Google Cloud standby environment

### 6. Validate Recovery Outcome
- Confirm application availability after failover
- Compare recovery results against the documented RTO/RPO targets
- Capture lessons learned and identify opportunities for further automation

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

This layout separates application code, infrastructure definitions, CI/CD workflows, and operational documentation to make the project easier to review and extend.

## Demo Application

The demo application simulates a production service and exposes endpoints that represent health, status, and recovery behavior.

### Endpoints

- `/health` — application health status  
- `/status` — platform and environment status  
- `/metrics` — example runtime metrics  
- `/failover` — simulated recovery behavior  

### Run Locally

```bash
cd app
pip install -r requirements.txt
python app.py


---

## ⚙️ Infrastructure Usage
```markdown
## Infrastructure Usage

### Prerequisites

- AWS account  
- Google Cloud account  
- Terraform installed  
- Docker installed  
- kubectl configured  
- Appropriate cloud credentials  

### Basic Setup

```bash
git clone https://github.com/brianmlasky-dev/multi-cloud-dr-platform.git
cd multi-cloud-dr-platform

terraform init
terraform plan
terraform apply

---

## Business Impact

- Reduces recovery time through automated infrastructure provisioning and documented procedures  
- Improves deployment consistency through CI/CD validation and security scanning  
- Demonstrates resilience beyond a single cloud failure domain  
- Connects infrastructure decisions directly to uptime, recovery objectives, and risk mitigation

## What I Would Improve Next

- Implement automated failover testing and validation  
- Add observability and alerting (metrics, logs, dashboards)  
- Improve secrets management and secure configuration handling  
- Enhance environment parity and rollback workflows  
- Perform cost analysis across recovery strategies

## Resume Highlights

- Designed and built a multi-cloud disaster recovery platform across AWS and Google Cloud  
- Provisioned infrastructure using Terraform (Infrastructure as Code)  
- Deployed containerized workloads with Docker and Kubernetes  
- Implemented CI/CD pipelines with GitHub Actions and integrated security scanning  
- Designed around defined RTO/RPO recovery objectives in a compliance-sensitive scenario

## About Me

I’m a Cloud / DevOps Engineer focused on building reliable, production-style cloud systems with an emphasis on resilience, automation, and operational discipline. This project reflects my approach to designing infrastructure with real-world constraints in mind.

## Contact

- **LinkedIn:** https://www.linkedin.com/in/brian-lasky-67464086/  
- **GitHub:** https://github.com/brianmlasky-dev  
