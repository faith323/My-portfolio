
variable "s3_bucket_domain_name" {
    description = "S3 regional bucket domain name"
    type = string
}

variable "s3_bucket_name" {
    description = "S3 bucket name"
    type = string
}

variable "s3_bucket_arn" {
    description = "S3 bucket ARN for policy attachment"
    type = string
}

variable "domain_aliases" {
    description = "Custom domains for cloudfront"
    type = list(string)
    default = []
}

variable "acm_certificate_arn" {
    description = "ACM certificate ARN from us-east-1"
    type = string
}

variable "origin_path" {
    description = "Origin path for cloudfront distribution"
    type = string
    default = ""
}

variable "tags" {
    description = "Tags for Cloudfront resources"
    type = map(string)
    default = {}
}