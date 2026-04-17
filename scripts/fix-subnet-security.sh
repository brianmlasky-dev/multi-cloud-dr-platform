#!/bin/bash

set -e

echo "🔧 Fixing subnet public IP exposure..."

# Find all Terraform files with subnets
FILES=$(grep -rl "aws_subnet" infrastructure/aws || true)

for FILE in $FILES; do
  echo "Processing $FILE..."

  # Replace true → false for public IP assignment
  sed -i 's/map_public_ip_on_launch *= *true/map_public_ip_on_launch = false/g' "$FILE"

  # If the setting doesn't exist, add it inside subnet blocks
  if ! grep -q "map_public_ip_on_launch" "$FILE"; then
    sed -i '/resource "aws_subnet"/,/}/ s/}/  map_public_ip_on_launch = false\n}/' "$FILE"
  fi

done

echo "✅ Subnet security patch applied"
