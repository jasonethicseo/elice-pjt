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
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.eks_cluster_security_group_id
}

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.eks_cluster_arn
}

output "eks_node_group_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
  value       = module.eks.eks_node_group_arn
}

# OpenVPN outputs
output "openvpn_instance_id" {
  description = "ID of the OpenVPN instance"
  value       = module.openvpn.instance_id
}

output "openvpn_public_ip" {
  description = "Public IP of the OpenVPN instance"
  value       = module.openvpn.public_ip
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
output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = module.cloudfront_cdn.distribution_id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = module.cloudfront_cdn.domain_name
}