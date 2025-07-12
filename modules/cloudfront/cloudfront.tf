resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for CloudFront to access S3 bucket"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.default_root_object

  origin {
    domain_name = var.s3_bucket_domain  # S3 버킷의 Regional Domain Name
    origin_id   = "S3-${var.s3_bucket_id}"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = "S3-${var.s3_bucket_id}"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = var.min_ttl
    default_ttl = var.default_ttl
    max_ttl     = var.max_ttl
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    # 만약 ACM 인증서를 사용하려면 아래를 활성화
    # acm_certificate_arn = var.acm_certificate_arn
    # ssl_support_method  = "sni-only"
    # minimum_protocol_version = "TLSv1.2_2019"
  }

  price_class = var.price_class

  tags = var.tags

}
