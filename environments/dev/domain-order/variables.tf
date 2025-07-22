# Order domain specific variables

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

variable "mock_eks_cluster_endpoint" {
  description = "Mock EKS cluster endpoint for development"
  type        = string
  default     = "https://mock-eks-endpoint.eks.ca-central-1.amazonaws.com"
}

variable "mock_eks_cluster_certificate_authority" {
  description = "Mock EKS cluster certificate authority for development"
  type        = string
  default     = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJTzNZbG1yR1dGc2d3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TXpBeE1ESXhOVEF3TURCYUZ3MHpNekF4TURJeE5UQXdNREJhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURJN05VYm5SZnh5eHo1RVlrS2VzM1U2VjdsbGJIRkZYTVg2NFJqS0s5T2VseTJCOHZXWVh0VjNvTXoKYytqT3NxUWg1Q3BUNHpPOUxyNzNEdkZicStqSGpwRTdZMkgwSkNJZTNGZXhDYXVYQXNSbWdGOTdYSGJITUJZZApJVmJRaHFMTm5OVzdvZUs4YlRrOHhVTFVGczRKNzJ6ZS9hTW1rSWpNQWZMT1VUTVBnQVhKb3hSWXNpT1JQelNKCnlEUUUzOG1MQkVHSWxSSkZGREd6dG1YZW9QemNYSGhaTmdNRTNPTmpxaDlydjZ0bmhSb3RlWlJ6eEVJSG5LQ3EKNzFrSU1jdVdrNG8wUWFPZWx2TjJPaFo3ZU9VTlNsVGJNVEpkU1crdVRjNFNZQ2xmTHdCOXRHNzJ6ODZKTlJhMgpNMnpwaTJEdXNqeWN6Y3BRNlNQQVhRNlU3SUFQQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSVFJwUzFMNzB6eXBpQ1l3SkM1ek1lMzRuZW5qQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQnNnMjJyUXB6TQp2K3BsMGdGOVBNY0ZlZzAzRGlMbUF4WkJNVVJneG5OWlRneEpsTEpyUUFRMjQ5L1pNZE5YQ3dOZmNFcktjNFVJCmF6NzA4eS9FeTNuWWllUXllZWJTWlpsa1lGS1k1WGdJQ2NEUTZZaWV6ejY0VlcyQ0hMOUdkdDFXRUhUWWNKN0wKa0xrZVBpcGZBZWQydGdkSkd6N01HaHBaOW1RVUxvb25tUERJZ2tGSDhWTVJ3d0paTTI2OWM0K3Q4VEx0SUJvTApraGNWV2VyZEVhU0Y3UnoyajN1M0pPYUNHb1VFQ1BjYy9qclpOVWJrTThyamdLYk5TZjJjRnFWSTRGVlpCRGZJCjVhTkhiNlJMaDJiMm8wbGdpMGkwWVJ6L01EQUNOZnI3Vnh3YkpqM0FZdlBqZXJoNkZXUlNoeXhQUE9WcWNUcTUKTWl6elp0Z0I4SHJ1Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
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
  default = "orderadmin"
}

variable "backup_retention_period" {
  type    = string
  default = "7"
}

variable "backup_window" {
  type    = string
  default = "03:00-04:00"
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

variable "ecr_allow_account_arns" {
  type        = list(string)
  description = "List of AWS account ARNs allowed to pull from ECR. Leave empty for no explicit cross-account access."
  default     = []
}