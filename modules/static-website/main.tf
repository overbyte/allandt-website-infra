terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
    alias = "acm"
    region = "us-east-1"
}
data "aws_acm_certificate" "_" {
  domain   = var.fqdn
  statuses = ["ISSUED"]
  provider = aws.acm
}

resource "aws_cloudfront_origin_access_identity" "_" {
  comment = var.name
}

resource "aws_s3_bucket" "_" {
  bucket  = var.name
  acl     = "private"
  tags    = var.tags
}

data "aws_iam_policy_document" "_" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket._.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity._.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "_" {
  bucket = aws_s3_bucket._.id
  policy = data.aws_iam_policy_document._.json
}

resource "aws_cloudfront_distribution" "_" {
  comment = var.name

  aliases         = [var.fqdn]
  enabled         = true
  is_ipv6_enabled = true

  # this is for SPA history routing
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/404/index.html"
  }

  origin {
    domain_name = aws_s3_bucket._.bucket_domain_name
    origin_id   = var.name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity._.cloudfront_access_identity_path

    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    target_origin_id = var.name

    allowed_methods = [
      "GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"
    ]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = var.disable_ttl ? 0 : 0
    default_ttl            = var.disable_ttl ? 0 : 3600
    max_ttl                = var.disable_ttl ? 0 : 86400

    forwarded_values {
      query_string = false
      headers = [
        "CloudFront-Viewer-Country"
      ]
      cookies {
        forward = "all"
      }
    }

    dynamic "lambda_function_association" {
      for_each = var.lambdas
      content {
        event_type   = lambda_function_association.value.event_type
        include_body = lookup(lambda_function_association.value, "include_body", null)
        lambda_arn   = lambda_function_association.value.lambda_arn
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate._.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
  # https://aws.amazon.com/cloudfront/pricing/
  price_class = "PriceClass_100"

  tags = var.tags
}

