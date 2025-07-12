output "bucket_name" {
  value = aws_s3_bucket.s3-bucket.id
}
output "bucket_arn" {
  value = aws_s3_bucket.s3-bucket.arn
}

output "bucket_regional_domain_name" {
  description = "S3 버킷의 Regional Domain Name"
  value       = aws_s3_bucket.s3-bucket.bucket_regional_domain_name
}
