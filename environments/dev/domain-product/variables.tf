# Product domain specific variables

variable "aws_region" {
  type    = string
  default = "ca-central-1"
}

# Development mode support
variable "mock_mode" {
  description = "Enable mock mode for development without core infrastructure"
  type        = bool
  default     = false
}

variable "mock_vpc_id" {
  description = "Mock VPC ID for development"
  type        = string
  default     = "vpc-mock12345678"
}

variable "mock_db_subnet_ids" {
  description = "Mock database subnet IDs for development"
  type        = list(string)
  default     = ["subnet-mockdb001", "subnet-mockdb002"]
}

variable "mock_service_subnet_ids" {
  description = "Mock service subnet IDs for development"
  type        = list(string)
  default     = ["subnet-mocksvc001", "subnet-mocksvc002"]
}

variable "mock_eks_cluster_name" {
  description = "Mock EKS cluster name for development"
  type        = string
  default     = "mock-eks-cluster"
}

variable "stage" {
  type    = string
  default = "dev"
}

variable "servicename" {
  type    = string
  default = "microservices"
}

variable "tags" {
  type = map(string)
  default = {}
}

# Microservice base variables
variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

variable "image_scan_on_push" {
  type    = bool
  default = true
}

# Database variables
variable "master_username" {
  type    = string
  default = "productadmin"
}

variable "backup_retention_period" {
  type    = string
  default = "7"
}

variable "backup_window" {
  type    = string
  default = "04:00-05:00"
}

variable "kms_key_id" {
  type    = string
  default = ""
}

variable "az" {
  type    = list(string)
  default = ["ca-central-1a", "ca-central-1b"]
}

variable "sg_allow_ingress_list_aurora" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "sg_allow_ingress_sg_list_aurora" {
  type    = list(string)
  default = []
}

variable "rds_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "rds_instance_auto_minor_version_upgrade" {
  type    = bool
  default = false
}

variable "rds_instance_publicly_accessible" {
  type    = bool
  default = false
}

variable "kms_arn" {
  type    = string
  default = ""
}