#!/bin/bash

set -e

echo "🔧 Restricting overly permissive egress rules..."

FILES=$(grep -rl "aws_security_group" infrastructure/aws || true)

for FILE in $FILES; do
  echo "Processing $FILE..."

  # Replace full open egress with VPC-limited egress
  sed -i 's/cidr_blocks = \["0.0.0.0\/0"\]/cidr_blocks = ["10.0.0.0\/16"]/g' "$FILE"

done

echo "✅ Egress restriction applied (limited to VPC CIDR)"
