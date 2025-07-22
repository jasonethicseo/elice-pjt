# Product domain outputs

# Microservice base outputs
output "product_ecr_repository_urls" {
  description = "URLs of the product ECR repositories"
  value       = module.product_microservice_base.ecr_repository_urls
}

output "product_namespace_name" {
  description = "Name of the product Kubernetes namespace"
  value       = module.product_microservice_base.namespace_name
}

output "product_service_account_name" {
  description = "Name of the product Kubernetes service account"
  value       = module.product_microservice_base.service_account_name
}

# Database outputs
output "product_db_cluster_endpoint" {
  description = "Aurora cluster endpoint for product database"
  value       = module.product_aurora.endpoint
  sensitive   = true
}

output "product_db_cluster_reader_endpoint" {
  description = "Aurora cluster reader endpoint for product database"
  value       = module.product_aurora.ro_endpoint
  sensitive   = true
}


# S3 outputs
output "product_s3_bucket_name" {
  description = "Name of the product assets S3 bucket"
  value       = module.product_s3.bucket_name
}

output "product_s3_bucket_arn" {
  description = "ARN of the product assets S3 bucket"
  value       = module.product_s3.bucket_arn
}