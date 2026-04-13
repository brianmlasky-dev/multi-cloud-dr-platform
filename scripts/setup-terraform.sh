#!/bin/bash

echo "📁 Setting up Terraform structure..."

# Root config
touch infrastructure/aws/providers.tf
touch infrastructure/aws/variables.tf
touch infrastructure/aws/outputs.tf
touch infrastructure/aws/vpc.tf
touch infrastructure/aws/ecs.tf
touch infrastructure/aws/rds.tf
touch infrastructure/aws/s3.tf
touch infrastructure/aws/route53.tf

# GCP config
touch infrastructure/gcp/providers.tf
touch infrastructure/gcp/variables.tf
touch infrastructure/gcp/outputs.tf
touch infrastructure/gcp/vpc.tf
touch infrastructure/gcp/cloudrun.tf
touch infrastructure/gcp/cloudsql.tf
touch infrastructure/gcp/gcs.tf

echo "✅ Terraform structure created!"
git add .
git commit -m "Add Terraform file structure for AWS and GCP"
git push
echo "🎉 Done!"
