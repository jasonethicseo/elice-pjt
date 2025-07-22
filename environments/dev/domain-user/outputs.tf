# User domain outputs

# Microservice base outputs
output "user_ecr_repository_urls" {
  description = "URLs of the user ECR repositories"
  value       = module.user_microservice_base.ecr_repository_urls
}

output "user_namespace_name" {
  description = "Name of the user Kubernetes namespace"
  value       = module.user_microservice_base.namespace_name
}

output "user_service_account_name" {
  description = "Name of the user Kubernetes service account"
  value       = module.user_microservice_base.service_account_name
}

# Database outputs
output "user_db_cluster_endpoint" {
  description = "Aurora cluster endpoint for user database"
  value       = module.user_aurora.endpoint
  sensitive   = true
}

output "user_db_cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint for user database"
  value       = module.user_aurora.ro_endpoint
  sensitive   = true
}


# S3 outputs
output "user_s3_bucket_name" {
  description = "Name of the user profiles S3 bucket"
  value       = module.user_s3.bucket_name
}

output "user_s3_bucket_arn" {
  description = "ARN of the user profiles S3 bucket"
  value       = module.user_s3.bucket_arn
}