#!/bin/bash

set -e

FILE="infrastructure/aws/vpc.tf"

echo "🔧 Applying secure ALB → ECS architecture..."

# Add ALB security group if not exists
if ! grep -q 'resource "aws_security_group" "alb"' $FILE; then
cat << 'EOF' >> $FILE

# ALB Security Group (public)
resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Allow HTTP from internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
EOF
fi

# Replace ECS security group ingress
sed -i 's/cidr_blocks = \["0.0.0.0\/0"\]/security_groups = [aws_security_group.alb.id]/g' $FILE

echo "✅ Network security patch applied"
