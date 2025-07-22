# Core infrastructure variables (shared resources)

variable "aws_region" {
  type    = string
  default = "ca-central-1"
}

variable "stage" {
  type    = string
  default = "production"
}

variable "servicename" {
  type    = string
  default = "microservices"
}

variable "tags" {
  type = map(string)
  default = {}
}

# VPC variables - Production uses different IP ranges
variable "vpc_ip_range" {
  type    = string
  default = "10.20.0.0/16"
}

variable "subnet_public_az1" {
  type    = string
  default = "10.20.1.0/24"
}

variable "subnet_public_az2" {
  type    = string
  default = "10.20.2.0/24"
}

variable "subnet_service_az1" {
  type    = string
  default = "10.20.3.0/24"
}

variable "subnet_service_az2" {
  type    = string
  default = "10.20.4.0/24"
}

variable "subnet_db_az1" {
  type    = string
  default = "10.20.5.0/24"
}

variable "subnet_db_az2" {
  type    = string
  default = "10.20.6.0/24"
}

variable "az" {
  type    = list(string)
  default = ["ca-central-1a", "ca-central-1b"]
}

# EKS variables
variable "sg_eks_cluster_ingress_list" {
  type    = list(string)
  default = ["10.20.0.0/16"]
}

variable "sg_allow_comm_ing" {
  type    = list(string)
  default = ["10.20.0.0/16"]
}

variable "s3_kms_key_id" {
  type    = string
  default = ""
}

variable "disk_kms_key_id" {
  type    = string
  default = ""
}

variable "rds_data_kms_arn" {
  type    = string
  default = ""
}

variable "sqs_kms_arn" {
  type    = string
  default = ""
}

variable "eks_kms_key_id" {
  type    = string
  default = ""
}

variable "smoke_test_repository_arn" {
  type    = string
  default = ""
}

# Production EKS - larger capacity
variable "desired_size" {
  type    = number
  default = 5
}

variable "min_size" {
  type    = number
  default = 3
}

variable "max_size" {
  type    = number
  default = 10
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.large", "t3.xlarge"]
}

# OpenVPN variables
variable "openvpn_allowed_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "openvpn_ami_id" {
  type    = string
  default = "ami-0a14a0a5716389b2d"
}

variable "openvpn_instance_type" {
  type    = string
  default = "t3.medium"
}

# S3 variables
variable "bucket_name" {
  type    = string
  default = "microservices-static-production"
}

variable "logging_bucket_id" {
  type    = string
  default = ""
}

variable "acmcertificatearn" {
  type    = string
  default = ""
}

variable "domain" {
  type    = string
  default = ""
}

variable "domain_3rd" {
  type    = string
  default = ""
}

variable "cors_configs" {
  type    = any
  default = null
}

variable "kms_arn" {
  type    = string
  default = ""
}

# MinIO variables - Production settings
variable "minio_root_user" {
  type    = string
  default = "minioadmin"
}

variable "minio_root_password" {
  type    = string
  default = "minioadmin123"
  sensitive = true
}

variable "minio_storage_size" {
  type    = string
  default = "100Gi"
}

variable "minio_replicas" {
  type    = number
  default = 4
}

variable "minio_image_tag" {
  type    = string
  default = "latest"
}

variable "minio_cpu_request" {
  type    = string
  default = "500m"
}

variable "minio_memory_request" {
  type    = string
  default = "1Gi"
}

variable "minio_cpu_limit" {
  type    = string
  default = "1000m"
}

variable "minio_memory_limit" {
  type    = string
  default = "2Gi"
}

variable "enable_external_access" {
  type    = bool
  default = false
}

variable "default_buckets" {
  type    = list(string)
  default = [
    "user-profiles", "user-avatars", "user-documents",
    "product-images", "product-docs", "product-videos",
    "order-receipts", "order-exports", "order-attachments"
  ]
}