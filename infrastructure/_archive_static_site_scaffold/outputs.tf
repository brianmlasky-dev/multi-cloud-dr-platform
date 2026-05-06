output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3_cloudfront.bucket_name
}

output "cloudfront_domain_name" {
  description = "CloudFront domain (your website URL)"
  value       = module.s3_cloudfront.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.s3_cloudfront.cloudfront_distribution_id
}
