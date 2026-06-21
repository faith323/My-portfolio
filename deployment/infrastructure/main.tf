locals {
  config = jsondecode(file("${path.module}/../../config.json"))
}


module "s3" {
  source = "./modules/s3"

  bucket_name = "${local.config.s3_bucket_name}"
  folder_name = "v1"
}


module "acm" {
  source = "./modules/acm"

  domain_name               = "${local.config.domain_name}"
  subject_alternative_names = ["${local.config.domain_aliases}"]

  tags = {
    Project = "${local.config.project_name}"
  }
}


module "route53_acm_validation" {
  source = "./modules/route53-acm-validation"

  hosted_zone_name          = "${local.config.domain_name}"
  domain_validation_options = module.acm.domain_validation_options
}


resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = module.acm.certificate_arn
  validation_record_fqdns = module.route53_acm_validation.validation_record_fqdns
}


module "route53_cname_records" {
  source = "./modules/route53"

  hosted_zone_name = "${local.config.hosted_zone_name}"

  cname_records = {
    "www" = {
      ttl   = 300
      value = module.cloudfront.domain_name
    }
  }
}


module "cloudfront" {
  source = "./modules/cloudfront"

  s3_bucket_domain_name = module.s3.bucket_domain_name
  s3_bucket_name        = module.s3.bucket_name
  s3_bucket_arn         = module.s3.bucket_arn
  domain_aliases        = ["${local.config.domain_aliases}"]
  acm_certificate_arn   = module.acm.certificate_arn
  origin_path           = "/v1"

  tags = {
    Project = "${local.config.project_name}"
  }
}


