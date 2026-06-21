variable "region" {
  description = "AWS region for general resources  (not ACM for Cloudfront)"
  type        = string
  default     = "us-east-1"
}

# variable "domain_name" {
#   description = "Primary domain name for ACM certificate"
#   type        = string
# }

variable "domain_aliases" {
  description = "CloudFront custom domains"
  type        = list(string)
  default     = []
}

# variable "bucket_name" {
#   description = "S3 bucket name"
#   type        = string
# }

variable "folder_name" {
  description = "S3 folder prefix"
  type        = string
  default     = "my_portfolio_v1"
}

variable "origin_path" {
  description = "CloudFront origin path inside S3 bucket"
  type        = string
  default     = "/"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}