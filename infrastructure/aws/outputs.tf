output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.main.arn
}

output "rds_primary_endpoint" {
  value = aws_db_instance.primary.endpoint
}

output "rds_replica_endpoint" {
  value = aws_db_instance.replica.endpoint
}

output "route53_zone_id" {
  value = aws_route53_zone.main.zone_id
}

output "route53_nameservers" {
  value = aws_route53_zone.main.name_servers
}

output "primary_health_check_id" {
  value = aws_route53_health_check.primary.id
}

output "dr_summary" {
  value = {
    rto_target         = "< 60 seconds"
    rpo_target         = "< 5 minutes"
    primary_region     = "us-east-1"
    secondary_region   = "us-central1 (GCP)"
    failover_mechanism = "Route 53 health check -> DNS cutover"
    dns_ttl_seconds    = 30
  }
}
