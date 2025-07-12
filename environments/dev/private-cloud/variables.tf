# OpenStack Connection Variables
variable "openstack_auth_url" {
  description = "OpenStack authentication URL"
  type        = string
  default     = "http://openstack.local:5000/v3"
}

variable "openstack_tenant_name" {
  description = "OpenStack tenant/project name"
  type        = string
  default     = "microservices"
}

variable "openstack_user_name" {
  description = "OpenStack username"
  type        = string
  default     = "microservices-user"
}

variable "openstack_password" {
  description = "OpenStack password"
  type        = string
  sensitive   = true
}

variable "openstack_region" {
  description = "OpenStack region"
  type        = string
  default     = "RegionOne"
}

# Network Configuration
variable "vpc_ip_range" {
  description = "CIDR block for the private network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "external_network_id" {
  description = "External network ID for internet access"
  type        = string
}

variable "external_network_name" {
  description = "External network name for floating IPs"
  type        = string
  default     = "public"
}

variable "dns_nameservers" {
  description = "List of DNS nameservers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "allocation_pool_start" {
  description = "Start IP address for allocation pool"
  type        = string
  default     = "10.0.0.100"
}

variable "allocation_pool_end" {
  description = "End IP address for allocation pool"
  type        = string
  default     = "10.0.0.200"
}

# Compute Configuration
variable "master_count" {
  description = "Number of Kubernetes master nodes"
  type        = number
  default     = 1
}

variable "worker_count" {
  description = "Number of Kubernetes worker nodes"
  type        = number
  default     = 2
}

variable "database_count" {
  description = "Number of database instances"
  type        = number
  default     = 1
}

variable "object_storage_node_count" {
  description = "Number of object storage nodes"
  type        = number
  default     = 1
}

variable "shared_storage_count" {
  description = "Number of shared storage volumes"
  type        = number
  default     = 3
}

# SSH Configuration
variable "public_key" {
  description = "Public SSH key for instance access"
  type        = string
}

# Storage Configuration
variable "enable_swift_storage" {
  description = "Enable Swift object storage containers"
  type        = bool
  default     = true
}

# Kubernetes Configuration
variable "client_certificate" {
  description = "Kubernetes client certificate (base64 encoded)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "client_key" {
  description = "Kubernetes client key (base64 encoded)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "cluster_ca_certificate" {
  description = "Kubernetes cluster CA certificate (base64 encoded)"
  type        = string
  default     = ""
  sensitive   = true
}