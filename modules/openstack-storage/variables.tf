variable "stage" {
  description = "Environment stage (dev, staging, production)"
  type        = string
}

variable "servicename" {
  description = "Service name"
  type        = string
}

variable "master_count" {
  description = "Number of master nodes"
  type        = number
  default     = 3
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "database_count" {
  description = "Number of database instances"
  type        = number
  default     = 3
}

variable "object_storage_node_count" {
  description = "Number of object storage nodes"
  type        = number
  default     = 3
}

variable "shared_storage_count" {
  description = "Number of shared storage volumes"
  type        = number
  default     = 5
}

# Volume Sizes (in GB)
variable "etcd_volume_size" {
  description = "Size of etcd volumes in GB"
  type        = number
  default     = 20
}

variable "worker_volume_size" {
  description = "Size of worker node storage volumes in GB"
  type        = number
  default     = 100
}

variable "database_volume_size" {
  description = "Size of database data volumes in GB"
  type        = number
  default     = 200
}

variable "database_backup_volume_size" {
  description = "Size of database backup volumes in GB"
  type        = number
  default     = 500
}

variable "object_storage_volume_size" {
  description = "Size of object storage volumes in GB"
  type        = number
  default     = 1000
}

variable "shared_storage_volume_size" {
  description = "Size of shared storage volumes in GB"
  type        = number
  default     = 50
}

# Swift Object Storage
variable "enable_swift_storage" {
  description = "Enable Swift object storage containers"
  type        = bool
  default     = true
}

variable "storage_containers" {
  description = "List of storage container names to create"
  type        = list(string)
  default = [
    "user-profiles",
    "user-avatars", 
    "user-documents",
    "product-images",
    "product-docs",
    "product-videos",
    "order-receipts",
    "order-exports",
    "order-attachments"
  ]
}

variable "swift_versioning_count" {
  description = "Number of versions to keep for Swift containers"
  type        = number
  default     = 10
}

# Backup Configuration
variable "enable_backups" {
  description = "Enable automatic backup volumes"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}