# ─────────────────────────────────────────
# AWS Secrets Manager — DB Password Rotation
#
# Wires automatic rotation onto the db-password secret using
# the AWS-managed SecretsManagerRDSPostgreSQLRotationSingleUser
# Lambda function (pre-built by AWS, no custom code required).
#
# The Lambda function is deployed from the AWS Serverless Application
# Repository when `terraform apply` runs for the first time.
#
# Rotation schedule: every 30 days (configurable via var.secret_rotation_days)
# ─────────────────────────────────────────

variable "secret_rotation_days" {
  description = "Number of days between automatic DB password rotations"
  type        = number
  default     = 30
}

# ── IAM role that Secrets Manager assumes to invoke the rotation Lambda ──────
resource "aws_iam_role" "secrets_rotation" {
  name = "${var.project_name}-secrets-rotation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_rotation_basic" {
  role       = aws_iam_role.secrets_rotation.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "secrets_rotation_vpc" {
  role       = aws_iam_role.secrets_rotation.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "secrets_rotation_sm" {
  name = "${var.project_name}-rotation-sm-policy"
  role = aws_iam_role.secrets_rotation.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage",
        ]
        Resource = [aws_secretsmanager_secret.db_password.arn]
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetRandomPassword"]
        Resource = ["*"]
      }
    ]
  })
}

# ── Security group for the rotation Lambda (must reach RDS) ──────────────────
resource "aws_security_group" "rotation_lambda" {
  name        = "${var.project_name}-rotation-lambda-sg"
  description = "Allows rotation Lambda to reach RDS on port 5432"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow HTTPS to Secrets Manager VPC endpoint / internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ── Rotation Lambda deployed from the AWS Serverless Application Repository ──
resource "aws_serverlessapplicationrepository_cloudformation_stack" "rotation_lambda" {
  name             = "${var.project_name}-db-rotation"
  application_id   = "arn:aws:serverlessrepo:us-east-1:297356227824:applications/SecretsManagerRDSPostgreSQLRotationSingleUser"
  semantic_version = "1.1.367"
  capabilities     = ["CAPABILITY_IAM", "CAPABILITY_RESOURCE_POLICY"]

  parameters = {
    endpoint            = "https://secretsmanager.${var.aws_region}.amazonaws.com"
    functionName        = "${var.project_name}-db-rotation-fn"
    vpcSubnetIds        = join(",", aws_subnet.private[*].id)
    vpcSecurityGroupIds = aws_security_group.rotation_lambda.id
  }
}

# ── Attach rotation to the secret ────────────────────────────────────────────
resource "aws_secretsmanager_secret_rotation" "db_password" {
  secret_id           = aws_secretsmanager_secret.db_password.id
  rotation_lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.rotation_lambda.outputs["RotationLambdaARN"]

  rotation_rules {
    automatically_after_days = var.secret_rotation_days
  }

  depends_on = [aws_serverlessapplicationrepository_cloudformation_stack.rotation_lambda]
}
