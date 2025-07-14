# Core infrastructure outputs (for domain modules to reference)

# VPC outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "service_subnet_ids" {
  description = "IDs of the service subnets"
  value       = module.vpc.service_subnet_ids
}

output "db_subnet_ids" {
  description = "IDs of the database subnets"
  value       = module.vpc.db_subnet_ids
}

output "service_subnet_az1_id" {
  description = "ID of service subnet in AZ1"
  value       = module.vpc.service_subnet_az1_id
}

output "service_subnet_az2_id" {
  description = "ID of service subnet in AZ2"
  value       = module.vpc.service_subnet_az2_id
}

# EKS outputs
output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.sg_eks_cluster_id
}


# OpenVPN outputs
output "openvpn_instance_id" {
  description = "ID of the OpenVPN instance"
  value       = module.openvpn.openvpn_instance_id
}

output "openvpn_public_ip" {
  description = "Public IP of the OpenVPN instance"
  value       = module.openvpn.openvpn_public_ip
}

# S3 outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3_static.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3_static.bucket_arn
}

# CloudFront outputs
output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = module.cloudfront_cdn.cloudfront_domain_name
}

# MinIO outputs
output "minio_endpoint" {
  description = "MinIO endpoint URL"
  value       = module.minio.endpoint
}

output "minio_console_endpoint" {
  description = "MinIO console endpoint URL"
  value       = module.minio.console_endpoint
}

output "minio_service_name" {
  description = "MinIO service name"
  value       = module.minio.service_name
}

output "minio_external_api_endpoint" {
  description = "MinIO external API endpoint"
  value       = module.minio.external_api_endpoint
}

output "minio_external_console_endpoint" {
  description = "MinIO external console endpoint"
  value       = module.minio.external_console_endpoint
}