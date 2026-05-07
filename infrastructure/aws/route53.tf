resource "aws_route53_zone" "main" {
  name = var.domain_name
  tags = {
    Name      = "${var.project_name}-hosted-zone"
    ManagedBy = "terraform"
  }
}

resource "aws_route53_health_check" "primary" {
  fqdn              = "app.${var.domain_name}"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = 3
  request_interval  = 30
  tags              = { Name = "${var.project_name}-primary-hc", Role = "primary" }
}

resource "aws_route53_health_check" "secondary" {
  fqdn              = var.gcp_cloudrun_fqdn
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = 3
  request_interval  = 30
  tags              = { Name = "${var.project_name}-secondary-hc", Role = "secondary" }
}

resource "aws_route53_record" "primary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.${var.domain_name}"
  type    = "CNAME"
  ttl     = 30
  failover_routing_policy { type = "PRIMARY" }
  set_identifier  = "primary"
  health_check_id = aws_route53_health_check.primary.id
  records         = [var.primary_alb_dns]
}

resource "aws_route53_record" "secondary" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.${var.domain_name}"
  type    = "CNAME"
  ttl     = 30
  failover_routing_policy { type = "SECONDARY" }
  set_identifier  = "secondary"
  health_check_id = aws_route53_health_check.secondary.id
  records         = [var.gcp_cloudrun_fqdn]
}
