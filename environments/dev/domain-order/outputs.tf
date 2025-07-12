# Order domain outputs

# Microservice base outputs
output "order_ecr_repository_urls" {
  description = "URLs of the order ECR repositories"
  value       = module.order_microservice_base.ecr_repository_urls
}

output "order_namespace_name" {
  description = "Name of the order Kubernetes namespace"
  value       = module.order_microservice_base.namespace_name
}

output "order_service_account_name" {
  description = "Name of the order Kubernetes service account"
  value       = module.order_microservice_base.service_account_name
}

# Database outputs
output "order_db_cluster_endpoint" {
  description = "Aurora cluster endpoint for order database"
  value       = module.order_aurora.aurora_cluster_endpoint
  sensitive   = true
}

output "order_db_cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint for order database"
  value       = module.order_aurora.aurora_cluster_reader_endpoint
  sensitive   = true
}

output "order_db_cluster_id" {
  description = "Aurora cluster identifier for order database"
  value       = module.order_aurora.aurora_cluster_id
}

# S3 outputs
output "order_s3_bucket_name" {
  description = "Name of the order documents S3 bucket"
  value       = module.order_s3.bucket_name
}

output "order_s3_bucket_arn" {
  description = "ARN of the order documents S3 bucket"
  value       = module.order_s3.bucket_arn
}