import pytest
import sys
import os

# Allow importing app from the parent directory
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import app as app_module


@pytest.fixture()
def client():
    app_module.app.config["TESTING"] = True
    with app_module.app.test_client() as c:
        yield c


# ── / ──────────────────────────────────────────────────────────────────────
class TestIndex:
    def test_returns_200(self, client):
        response = client.get("/")
        assert response.status_code == 200

    def test_content_type_html(self, client):
        response = client.get("/")
        assert "text/html" in response.content_type


# ── /health ────────────────────────────────────────────────────────────────
class TestHealth:
    def test_returns_200(self, client):
        response = client.get("/health")
        assert response.status_code == 200

    def test_json_status_healthy(self, client):
        data = client.get("/health").get_json()
        assert data["status"] == "healthy"

    def test_json_has_required_fields(self, client):
        data = client.get("/health").get_json()
        for field in ("status", "cloud", "environment", "version", "uptime", "timestamp"):
            assert field in data, f"Missing field: {field}"

    def test_timestamp_ends_with_z(self, client):
        data = client.get("/health").get_json()
        assert data["timestamp"].endswith("Z")


# ── /status ────────────────────────────────────────────────────────────────
class TestStatus:
    def test_returns_200(self, client):
        response = client.get("/status")
        assert response.status_code == 200

    def test_json_has_platform_fields(self, client):
        data = client.get("/status").get_json()
        for field in ("platform", "active_cloud", "region", "role", "rto_target", "rpo_target", "services"):
            assert field in data, f"Missing field: {field}"

    def test_services_block_present(self, client):
        data = client.get("/status").get_json()
        services = data["services"]
        for key in ("compute", "database", "storage", "dns", "monitoring"):
            assert key in services, f"Missing service: {key}"

    def test_aws_defaults(self, client, monkeypatch):
        monkeypatch.setattr(app_module, "CLOUD_PROVIDER", "aws")
        data = client.get("/status").get_json()
        assert data["region"] == "us-east-1"
        assert data["role"] == "PRIMARY"

    def test_gcp_labels(self, client, monkeypatch):
        monkeypatch.setattr(app_module, "CLOUD_PROVIDER", "gcp")
        data = client.get("/status").get_json()
        assert data["region"] == "us-central1"
        assert data["role"] == "STANDBY"


# ── /failover ──────────────────────────────────────────────────────────────
class TestFailover:
    def test_returns_200(self, client):
        response = client.get("/failover")
        assert response.status_code == 200

    def test_json_is_simulation(self, client):
        data = client.get("/failover").get_json()
        assert data["failover_simulation"] is True

    def test_json_has_required_fields(self, client):
        data = client.get("/failover").get_json()
        for field in ("from_cloud", "to_cloud", "steps", "estimated_rto", "estimated_rpo", "status"):
            assert field in data, f"Missing field: {field}"

    def test_steps_is_non_empty_list(self, client):
        data = client.get("/failover").get_json()
        assert isinstance(data["steps"], list)
        assert len(data["steps"]) > 0

    def test_target_cloud_flips_from_aws(self, client, monkeypatch):
        monkeypatch.setattr(app_module, "CLOUD_PROVIDER", "aws")
        data = client.get("/failover").get_json()
        assert data["to_cloud"] == "GCP"

    def test_target_cloud_flips_from_gcp(self, client, monkeypatch):
        monkeypatch.setattr(app_module, "CLOUD_PROVIDER", "gcp")
        data = client.get("/failover").get_json()
        assert data["to_cloud"] == "AWS"


# ── /metrics ───────────────────────────────────────────────────────────────
class TestMetrics:
    def test_returns_200(self, client):
        response = client.get("/metrics")
        assert response.status_code == 200

    def test_json_has_required_fields(self, client):
        data = client.get("/metrics").get_json()
        for field in (
            "uptime", "requests_served", "avg_response_time_ms",
            "error_rate_percent", "cpu_utilization_percent",
            "memory_utilization_percent", "db_connections_active",
            "cloud", "timestamp",
        ):
            assert field in data, f"Missing field: {field}"

    def test_numeric_ranges(self, client):
        data = client.get("/metrics").get_json()
        assert 10000 <= data["requests_served"] <= 99999
        assert 0 < data["avg_response_time_ms"] < 100
        assert 0 <= data["error_rate_percent"] < 1
        assert 0 < data["cpu_utilization_percent"] < 100
        assert 0 < data["memory_utilization_percent"] < 100
