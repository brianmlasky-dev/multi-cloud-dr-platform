# ─────────────────────────────────────────
# Route 53 - DNS Failover & Health Checks
# ─────────────────────────────────────────

resource "aws_route53_health_check" "primary" {
  fqdn              = "app.crestlinefinancial.com"
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
  name = "crestlinefinancial.com"
}

resource "aws_route53_health_check" "secondary" {
  fqdn              = "standby.crestlinefinancial.com"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "${var.project_name}-standby-health-check"
  }
}

resource "aws_route53_record" "primary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.crestlinefinancial.com"
  type    = "A"

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier  = "primary"
  health_check_id = aws_route53_health_check.primary.id

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "secondary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.crestlinefinancial.com"
  type    = "A"

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier  = "secondary"
  health_check_id = aws_route53_health_check.secondary.id

  alias {
    name                   = "standby.crestlinefinancial.com"
    zone_id                = aws_route53_zone.main.zone_id
    evaluate_target_health = true
  }
}
