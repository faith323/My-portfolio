resource "aws_cloudfront_origin_access_control" "this" {
    name = "website-oac"
    description = "OAC for private S3 access"
    origin_access_control_origin_type = "s3"
    signing_behavior = "always"
    signing_protocol = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
    enabled = true
    comment = "Cloudfront distribution for my_portfolio"
    default_root_object = "index.html"

    aliases = var.domain_aliases

    origin {
        domain_name = var.s3_bucket_domain_name
        origin_id   = "s3-origin"
        origin_path = var.origin_path
        origin_access_control_id = aws_cloudfront_origin_access_control.this.id
    }

    default_cache_behavior {
        target_origin_id = "s3-origin"

        allowed_methods = ["GET", "HEAD"]
        cached_methods  = ["GET", "HEAD"]

        viewer_protocol_policy = "redirect-to-https"

        compress = true

        # AWS managed policy: Cachingoptimized
        cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    }

    restrictions {
      geo_restriction {
        restriction_type = "none"
      }
    }

    viewer_certificate {
        acm_certificate_arn = var.acm_certificate_arn
        ssl_support_method  = "sni-only"
        minimum_protocol_version = "TLSv1.2_2021"
    }

    # Pay-as-you-go pricing model
    price_class = "PriceClass_100"

    tags = var.tags
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = var.s3_bucket_name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"

        Principal = {
          Service = "cloudfront.amazonaws.com"
        }

        Action = "s3:GetObject"

        Resource = "${var.s3_bucket_arn}/*"

        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.this.arn
          }
        }
      }
    ]
  })
}