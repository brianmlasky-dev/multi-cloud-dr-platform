# ═══════════════════════════════════════════════════════════════════
# RDS — NorthStar Commerce DR Platform
# Primary: PostgreSQL 15.4, db.t3.micro, us-east-1a
# Replica: Cross-AZ read replica in us-east-1b (DR demonstration)
#
# SIMULATION NOTE: This infrastructure is defined for portfolio
# demonstration of multi-AZ DR architecture. The read replica
# pattern mirrors production DR runbooks from oilfield production
# supervision — if primary fails, replica promotes in < 60 seconds.
# terraform destroy after each session to avoid charges.
# ═══════════════════════════════════════════════════════════════════

# ── RDS Security Group ───────────────────────────────────────────
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "RDS PostgreSQL access — ECS tasks only"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "PostgreSQL from ECS tasks"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "No outbound needed for RDS"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# ── DB Subnet Group (requires 2 AZs minimum) ────────────────────
resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Private subnets for RDS — no internet access"
  subnet_ids  = module.vpc.private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# ── Primary RDS Instance ─────────────────────────────────────────
resource "aws_db_instance" "primary" {
  identifier        = "${var.project_name}-primary"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "northstar_commerce"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # DR Configuration
  availability_zone       = "${var.aws_region}a"
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  # Portfolio cost controls
  skip_final_snapshot = true  # SIMULATION: would be false in production
  deletion_protection = false # SIMULATION: would be true in production
  publicly_accessible = false # RDS stays private — no public exposure

  # Performance Insights (free tier 7 days)
  performance_insights_enabled = true

  tags = {
    Name = "${var.project_name}-primary-rds"
    Role = "primary"
    DR   = "source"
  }
}

# ── Cross-AZ Read Replica (DR Target) ───────────────────────────
# SIMULATION NOTE: In a real failover event, this replica would be
# promoted to primary via: aws rds promote-read-replica
# RTO target: < 60 seconds | RPO target: < 5 minutes
resource "aws_db_instance" "replica" {
  identifier          = "${var.project_name}-replica"
  replicate_source_db = aws_db_instance.primary.identifier
  instance_class      = "db.t3.micro"

  # Cross-AZ placement — key DR requirement
  availability_zone      = "${var.aws_region}b"
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Replica-specific settings
  backup_retention_period = 0     # Replicas don't need their own backups
  skip_final_snapshot     = true  # SIMULATION: would be false in production
  deletion_protection     = false # SIMULATION: would be true in production
  publicly_accessible     = false

  tags = {
    Name = "${var.project_name}-replica-rds"
    Role = "replica"
    DR   = "failover-target"
  }
}
