output "cloudfront_domain_name" {
  description = "CloudFront 배포의 도메인 이름"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "origin_access_identity" {
  description = "CloudFront Origin Access Identity"
  value       = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
}
