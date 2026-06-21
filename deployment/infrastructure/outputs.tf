
# CloudFront Module Outputs
output "distribution_id" {
  value = module.cloudfront.distribution_id
}

output "s3_bucket_name" {
  value = module.s3.bucket_name
}