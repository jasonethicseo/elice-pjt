resource "aws_s3_bucket" "s3-bucket" {
  bucket = "${var.stage}-${var.servicename}-${var.bucket_name}"
### add after create logging bucket
#  logging {
#    target_bucket = var.logging_bucket_id
#    target_prefix = "${var.s3_access_logging_prefix}/smp-eks-node"
#  }

  tags = merge(tomap({
         Name = "${var.stage}-${var.servicename}-${var.bucket_name}"}),
        var.tags)

}

resource "aws_s3_bucket_logging" "logging" {
  count = var.islog ? 0:1 ##create if false(only private bucket)
  bucket = aws_s3_bucket.s3-bucket.id

  target_bucket = var.logging_bucket_id
  target_prefix = "s3/${aws_s3_bucket.s3-bucket.id}/"
}

resource "aws_s3_bucket_acl" "s3-acl-pri" {
  count                = var.ispub ? 0 : 1 ##create if false(only private bucket)
  bucket = aws_s3_bucket.s3-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "s3-lifecycle-config" {
  bucket = aws_s3_bucket.s3-bucket.bucket

  rule {
    id = "default"

    filter {
      prefix = ""
    }

    expiration {
      days = var.expiration_days
    }

    status = var.lifecycle_rule_enabled ? "Enabled" : "Disabled"

    transition {
      days          = var.STANDARD_IA_Transition_days
      storage_class = "STANDARD_IA"
    }
    noncurrent_version_transition {
      noncurrent_days = var.STANDARD_IA_Transition_days
      storage_class   = "STANDARD_IA"
    }

    transition {
      days          = var.GLACIER_Transition_days
      storage_class = "GLACIER"
    }
    noncurrent_version_transition {
      noncurrent_days = var.GLACIER_Transition_days
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.expiration_days
    }

  }

}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-encryption-kms" {
  count                = length(var.kms_arn) > 0 ? 1 : 0
  bucket = aws_s3_bucket.s3-bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-encryption" {
  count                = length(var.kms_arn) > 0 ? 0 : 1
  bucket = aws_s3_bucket.s3-bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}


resource "aws_s3_bucket_public_access_block" "s3-bucket-public-access-block-pub" {
  count                = var.ispub ? 1 : 0 ##create if true(only public)
  bucket = aws_s3_bucket.s3-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_public_access_block" "s3-bucket-public-access-block-pri" {
  count                = var.ispub ? 0 : 1 ##create if false(only private bucket)
  bucket = aws_s3_bucket.s3-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "s3-versioning" {
  count = var.versioning_enabled ? 1 : 0
  bucket = aws_s3_bucket.s3-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "s3-public-bucket-policy" {
  count                = var.ispub ? 1 : 0 ##create if true(only public)
  bucket = aws_s3_bucket.s3-bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
    {
      "Sid": "bucket account policy",
      "Effect": "Allow",
      "Principal": {
          "AWS": [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${var.stage}-${var.servicename}-${var.bucket_name}",
        "arn:aws:s3:::${var.stage}-${var.servicename}-${var.bucket_name}/*"            
      ]
    },
    {
      "Sid": "file upload policy",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        ]
      },
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::${var.stage}-${var.servicename}-${var.bucket_name}",
        "arn:aws:s3:::${var.stage}-${var.servicename}-${var.bucket_name}/*"            
      ]
    },
    {
      "Sid": "AllowSSLRequestsOnly",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
                "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-${var.bucket_name}-bucket",
                "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-${var.bucket_name}-bucket/*"
            ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
        "Sid": "origin access identity iam",
        "Effect": "Allow",
        "Principal": {
            "AWS": "${aws_cloudfront_origin_access_identity.s3-cdn[0].iam_arn}"
        },
        "Action": [
            "s3:GetObject",
            "s3:ListBucket"
        ],
        "Resource": [
                "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-${var.bucket_name}-bucket",
                "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-${var.bucket_name}-bucket/*"
            ]
    }
  ]
}
POLICY
}


resource "aws_s3_bucket_policy" "s3-bucket-policy" {
  count                = (!var.ispub && !var.isCFN) ? 1 : 0 ##create if true(only for private buckets without Cloudfront)
  bucket = aws_s3_bucket.s3-bucket.id
  policy = <<POLICY
{
      "Version": "2012-10-17",
      "Statement": [
      {
        "Sid": "bucket account policy",
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket"
        ],
        "Resource": [
                  "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-${var.bucket_name}-bucket",
                  "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-${var.bucket_name}-bucket/*"
              ],
        "Principal": {
          "AWS": [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        }
    },
    {
      "Sid": "bucket account policy",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
                "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-${var.bucket_name}-bucket",
                "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-${var.bucket_name}-bucket/*"
            ],
      "Principal": {
        "AWS": [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        ]
      }
    },
    {
      "Sid": "AllowSSLRequestsOnly",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
                "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-${var.bucket_name}-bucket",
                "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-${var.bucket_name}-bucket/*"
            ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_policy" "s3-private-cloudfront-bucket-policy" {
  count                = (!var.ispub && var.isCFN) ? 1 : 0 ##create if true(only for private buckets with Cloudfront)
  bucket = aws_s3_bucket.s3-bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "bucket account policy",
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket"
        ],
        "Resource": [
                  "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-${var.bucket_name}-bucket",
                  "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-${var.bucket_name}-bucket/*"
              ],
        "Principal": {
          "AWS": [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        }
      },
      {
        "Sid": "bucket account policy",
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        "Resource": [
            "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-${var.bucket_name}-bucket",
            "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-${var.bucket_name}-bucket/*"
        ],
        "Principal": {
          "AWS": [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
        }
      },
      {
        "Sid": "AllowSSLRequestsOnly",
        "Effect": "Deny",
        "Principal": "*",
        "Action": "s3:*",
        "Resource": [
            "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-${var.bucket_name}-bucket",
            "arn:aws:s3:::aws-s3-${var.stage}-${var.servicename}-${var.bucket_name}-bucket/*"
        ],
        "Condition": {
          "Bool": {
            "aws:SecureTransport": "false"
          }
        }
      },
      {
        "Sid": "origin access identity iam",
        "Effect": "Allow",
        "Principal": {
            "AWS": "${aws_cloudfront_origin_access_identity.s3-cdn[0].iam_arn}"
        },
        "Action": [
          "s3:GetObject"
        ],
        "Resource": [
            "arn:aws:s3:::${var.stage}-${var.servicename}-${var.bucket_name}/apks/debug/*"
        ]
      }
    ]
}
POLICY
}

resource "aws_s3_bucket_cors_configuration" "s3-public-cors-config" {
  count  = var.cors_configs == null ? 0 : 1
  bucket = aws_s3_bucket.s3-bucket.bucket

  dynamic "cors_rule" {
    for_each = var.cors_configs
    content {
      allowed_headers = cors_rule.value["allowed_headers"]
      allowed_methods = cors_rule.value["allowed_methods"]
      allowed_origins = cors_rule.value["allowed_origins"]
      expose_headers  = cors_rule.value["expose_headers"]
      max_age_seconds = cors_rule.value["max_age_seconds"]
    }
  }
}

##Public bucket CDN
resource "aws_cloudfront_origin_access_identity" "s3-cdn" {
  count   = var.isCFN ? 1 : 0 #(only when using CloudFront)
  comment =  "${var.stage}-${var.servicename}-${var.bucket_name} cdn access identity"
}

resource "aws_cloudfront_distribution" "s3-distribution" {
  count = var.ispub ? 1 : 0 #(only when using CloudFront)
  origin {
    domain_name = aws_s3_bucket.s3-bucket.bucket_regional_domain_name
    origin_id   =  aws_s3_bucket.s3-bucket.arn
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3-cdn[0].cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      # locations        = ["US", "KR"]
    }
  }

  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  comment             = "${var.stage}-${var.servicename}-${var.bucket_name} cdn"
  default_root_object = "index.html"

  # 임시 로깅 조건부 생성
  dynamic "logging_config" {
    for_each = (var.logging_bucket_id != "") ? [1] : []
    content {
      include_cookies = false
      bucket          = "${var.logging_bucket_id}.s3.amazonaws.com"
      prefix          = "cdn/${aws_s3_bucket.s3-bucket.id}/"
    }
  }

  aliases = [] #"${var.domain_3rd}.${var.domain}" 임시 비활성화

  custom_error_response {
    error_caching_min_ttl = 300
    error_code =  404
    response_code = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code =  403
    response_code = 200
    response_page_path = "/index.html"
  }
  
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.s3-bucket.arn
    compress = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 60
    default_ttl            = 60
    max_ttl                = 60   
  }

  price_class = "PriceClass_200"

  web_acl_id = var.waf_acl_id

  tags = {
    Name = "${var.stage}-${var.servicename}-${var.bucket_name}"
    servicename = "${var.servicename}"
    stage = "${var.stage}"
    billing       = "aws_lg_biz@lgcns.com"
    department    = "DnAB2CApp"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn = var.acmcertificatearn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [viewer_certificate[0].cloudfront_default_certificate]
  }

}

data "aws_ssm_parameter" "private-distribution-sign-pub-key-data" {
  count = (!var.ispub && var.isCFN) ? 1 : 0 #(only when using CloudFront)
  name  = "/cloudfront/presigned/${aws_s3_bucket.s3-bucket.id}/public_key.pem"
}

resource "aws_cloudfront_public_key" "private-distribution-sign-pub-key" {
  count       = (!var.ispub && var.isCFN) ? 1 : 0 #(only when using CloudFront)
  comment     = "CFN public key for ${aws_s3_bucket.s3-bucket.id}"
  encoded_key = data.aws_ssm_parameter.private-distribution-sign-pub-key-data[0].value
  name        = "cfn-pubkey-${var.stage}-${var.servicename}-${var.bucket_name}"
}

resource "aws_cloudfront_key_group" "private-distribution-sign-key-group" {
  count   = (!var.ispub && var.isCFN) ? 1 : 0 #(only when using CloudFront)
  comment = "CFN key group for ${aws_s3_bucket.s3-bucket.id}"
  items   = [aws_cloudfront_public_key.private-distribution-sign-pub-key[0].id]
  name    = "cfn-kg-${var.stage}-${var.servicename}-${var.bucket_name}"
}

resource "aws_cloudfront_distribution" "s3-private-distribution" {
  count = (!var.ispub && var.isCFN) ? 1 : 0 #(only when using CloudFront)
  origin {
    domain_name = aws_s3_bucket.s3-bucket.bucket_regional_domain_name
    origin_id   =  aws_s3_bucket.s3-bucket.arn
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3-cdn[0].cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      # locations        = ["US", "KR"]
    }
  }

  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  comment             = "${var.stage}-${var.servicename}-${var.bucket_name} cdn"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    #bucket          = "mylogs.s3.amazonaws.com"
    bucket          = "${var.logging_bucket_id}.s3.amazonaws.com"
    prefix          = "cdn/${aws_s3_bucket.s3-bucket.id}/"
  }

  aliases = ["${var.domain_3rd}.${var.domain}"]

  custom_error_response {
    error_caching_min_ttl = 300
    error_code =  404
    response_code = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code =  403
    response_code = 200
    response_page_path = "/index.html"
  }
  
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.s3-bucket.arn
    compress = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 60
    default_ttl            = 60
    max_ttl                = 60   
    trusted_key_groups = [aws_cloudfront_key_group.private-distribution-sign-key-group[0].id]
  }

  price_class = "PriceClass_200"

  web_acl_id = var.waf_acl_id

  tags = {
    Name = "${var.stage}-${var.servicename}-${var.bucket_name}"
    servicename = "${var.servicename}"
    stage = "${var.stage}"
    billing       = "aws_lg_biz@lgcns.com"
    department    = "DnAB2CApp"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn = var.acmcertificatearn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [viewer_certificate[0].cloudfront_default_certificate]
  }

}