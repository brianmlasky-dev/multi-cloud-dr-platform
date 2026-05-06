# ─────────────────────────────────────────────────────────────
# Multi-Cloud DR Platform - Demo Application
# Author: Brian M. Lasky
# Project: NorthStar Commerce DR Platform
# GitHub:  github.com/brianmlasky/multi-cloud-dr-platform
# ─────────────────────────────────────────────────────────────

from flask import Flask, jsonify, render_template
import os
import datetime
import random

app = Flask(__name__)

CLOUD_PROVIDER = os.environ.get("CLOUD_PROVIDER", "aws")
ENVIRONMENT    = os.environ.get("ENVIRONMENT", "production")
VERSION        = "1.0.0"
START_TIME     = datetime.datetime.utcnow()


def get_uptime():
    delta = datetime.datetime.utcnow() - START_TIME
    hours, remainder = divmod(int(delta.total_seconds()), 3600)
    minutes, seconds = divmod(remainder, 60)
    return f"{hours}h {minutes}m {seconds}s"


def get_region():
    return "us-east-1" if CLOUD_PROVIDER == "aws" else "us-central1"


def get_role():
    return "PRIMARY" if CLOUD_PROVIDER == "aws" else "STANDBY"


# ─────────────────────────────────────────
# Routes
# ─────────────────────────────────────────

@app.route("/")
def index():
    return render_template(
        "index.html",
        cloud=CLOUD_PROVIDER.upper(),
        environment=ENVIRONMENT,
        version=VERSION,
        uptime=get_uptime(),
        region=get_region(),
        status=get_role(),
    )


@app.route("/health")
def health():
    return jsonify({
        "status":      "healthy",
        "cloud":       CLOUD_PROVIDER,
        "environment": ENVIRONMENT,
        "version":     VERSION,
        "uptime":      get_uptime(),
        "timestamp":   datetime.datetime.utcnow().isoformat() + "Z",
    }), 200


@app.route("/status")
def status():
    return jsonify({
        "platform":             "NorthStar Commerce DR Platform",
        "author":               "Brian M. Lasky",
        "active_cloud":         CLOUD_PROVIDER.upper(),
        "region":               get_region(),
        "role":                 get_role(),
        "environment":          ENVIRONMENT,
        "version":              VERSION,
        "uptime":               get_uptime(),
        "rto_target":           "5-15 minutes",
        "rpo_target":           "15-60 minutes",
        "availability_target":  "99.95%",
        "services": {
            "compute":    "ECS Fargate"          if CLOUD_PROVIDER == "aws" else "Cloud Run",
            "database":   "RDS PostgreSQL"       if CLOUD_PROVIDER == "aws" else "Cloud SQL PostgreSQL",
            "storage":    "S3 Bucket"            if CLOUD_PROVIDER == "aws" else "GCS Bucket",
            "dns":        "Route 53 Failover",
            "monitoring": "CloudWatch"           if CLOUD_PROVIDER == "aws" else "GCP Monitoring",
        },
        "timestamp": datetime.datetime.utcnow().isoformat() + "Z",
    }), 200


@app.route("/failover")
def failover():
    target = "gcp" if CLOUD_PROVIDER == "aws" else "aws"
    return jsonify({
        "failover_simulation": True,
        "note":                "Simulated failover sequence — infrastructure wired via Terraform",
        "from_cloud":          CLOUD_PROVIDER.upper(),
        "to_cloud":            target.upper(),
        "steps": [
            "1. Health check failure detected on primary",
            "2. Route 53 DNS failover triggered",
            "3. Traffic rerouted to standby region",
            "4. Standby Cloud Run scaled to handle load",
            "5. Cloud SQL replica promoted to primary",
            "6. Service restored — RTO target met",
        ],
        "estimated_rto": "5-15 minutes",
        "estimated_rpo": "15-60 minutes",
        "status":        "SIMULATION COMPLETE",
        "timestamp":     datetime.datetime.utcnow().isoformat() + "Z",
    }), 200


@app.route("/metrics")
def metrics():
    # Note: values are simulated for demonstration purposes
    return jsonify({
        "note":                        "Simulated metrics — for architecture demonstration",
        "uptime":                      get_uptime(),
        "cloud":                       CLOUD_PROVIDER.upper(),
        "requests_served":             random.randint(10000, 99999),
        "avg_response_time_ms":        round(random.uniform(12.5, 45.0), 2),
        "error_rate_percent":          round(random.uniform(0.01, 0.05), 3),
        "cpu_utilization_percent":     round(random.uniform(15.0, 45.0), 1),
        "memory_utilization_percent":  round(random.uniform(30.0, 60.0), 1),
        "db_connections_active":       random.randint(5, 25),
        "timestamp":                   datetime.datetime.utcnow().isoformat() + "Z",
    }), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=False)
