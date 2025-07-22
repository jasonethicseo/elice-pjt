variable "stage" {
  description = "Environment stage (dev, staging, production)"
  type        = string
}

variable "servicename" {
  description = "Service name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for MinIO deployment"
  type        = list(string)
}


variable "minio_root_user" {
  description = "MinIO root user"
  type        = string
  default     = "minioadmin"
}

variable "minio_root_password" {
  description = "MinIO root password"
  type        = string
  sensitive   = true
}

variable "minio_storage_size" {
  description = "Storage size per MinIO instance"
  type        = string
  default     = "10Gi"
}

variable "minio_replicas" {
  description = "Number of MinIO replicas"
  type        = number
  default     = 1
}

variable "minio_image_tag" {
  description = "MinIO image tag"
  type        = string
  default     = "latest"
}

variable "minio_cpu_request" {
  description = "CPU request for MinIO pods"
  type        = string
  default     = "250m"
}

variable "minio_memory_request" {
  description = "Memory request for MinIO pods"
  type        = string
  default     = "256Mi"
}

variable "minio_cpu_limit" {
  description = "CPU limit for MinIO pods"
  type        = string
  default     = "500m"
}

variable "minio_memory_limit" {
  description = "Memory limit for MinIO pods"
  type        = string
  default     = "512Mi"
}

variable "enable_external_access" {
  description = "Enable external access via LoadBalancer"
  type        = bool
  default     = false
}

variable "default_buckets" {
  description = "Default buckets to create"
  type        = list(string)
  default     = ["uploads", "backups", "logs"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}