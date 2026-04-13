# ─────────────────────────────────────────
# Route 53 - DNS Failover & Health Checks
# ─────────────────────────────────────────

resource "aws_route53_health_check" "primary" {
  fqdn              = "app.northstarcommerce.com"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "${var.project_name}-health-check"
  }
}

resource "aws_route53_zone" "main" {
  name = "northstarcommerce.com"
}

resource "aws_route53_record" "primary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.northstarcommerce.com"
  type    = "A"

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier  = "primary"
  health_check_id = aws_route53_health_check.primary.id

  alias {
    name                   = "primary-alb.northstarcommerce.com"
    zone_id                = aws_route53_zone.main.zone_id
    evaluate_target_health = true
  }
}
