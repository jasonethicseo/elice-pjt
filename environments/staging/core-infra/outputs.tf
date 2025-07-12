# Core infrastructure outputs

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "service_subnet_ids" {
  description = "Service subnet IDs"
  value       = module.vpc.service_subnet_ids
}

output "db_subnet_ids" {
  description = "Database subnet IDs"
  value       = module.vpc.db_subnet_ids
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority" {
  description = "EKS cluster certificate authority"
  value       = module.eks.cluster_certificate_authority
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_node_group_arn" {
  description = "EKS node group ARN"
  value       = module.eks.node_group_arn
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3_static.bucket_name
}

output "s3_bucket_regional_domain_name" {
  description = "S3 bucket regional domain name"
  value       = module.s3_static.bucket_regional_domain_name
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront_cdn.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront_cdn.cloudfront_distribution_id
}

output "cloudfront_origin_access_identity" {
  description = "CloudFront Origin Access Identity"
  value       = module.cloudfront_cdn.origin_access_identity
}

output "openvpn_public_ip" {
  description = "OpenVPN server public IP"
  value       = module.openvpn.openvpn_public_ip
}

output "openvpn_instance_id" {
  description = "OpenVPN instance ID"
  value       = module.openvpn.openvpn_instance_id
}

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