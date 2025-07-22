variable "stage" {
  description = "Environment stage (dev, staging, production)"
  type        = string
}

variable "servicename" {
  description = "Service name"
  type        = string
}

variable "network_name" {
  description = "Name of the network to attach instances to"
  type        = string
}

variable "k8s_security_group_name" {
  description = "Name of the Kubernetes security group"
  type        = string
}

variable "db_security_group_name" {
  description = "Name of the database security group"
  type        = string
}

variable "image_name" {
  description = "Name of the OS image to use"
  type        = string
  default     = "Ubuntu 22.04"
}

variable "master_count" {
  description = "Number of Kubernetes master nodes"
  type        = number
  default     = 3
}

variable "worker_count" {
  description = "Number of Kubernetes worker nodes"
  type        = number
  default     = 3
}

variable "database_count" {
  description = "Number of database instances"
  type        = number
  default     = 3
}

variable "master_flavor" {
  description = "Flavor for master nodes"
  type        = string
  default     = "m1.large"
}

variable "worker_flavor" {
  description = "Flavor for worker nodes"
  type        = string
  default     = "m1.xlarge"
}

variable "database_flavor" {
  description = "Flavor for database instances"
  type        = string
  default     = "m1.medium"
}

variable "loadbalancer_flavor" {
  description = "Flavor for load balancer instance"
  type        = string
  default     = "m1.small"
}

variable "public_key" {
  description = "Public SSH key for instance access"
  type        = string
}

variable "enable_loadbalancer" {
  description = "Whether to create a load balancer instance"
  type        = bool
  default     = true
}

variable "enable_external_access" {
  description = "Whether to assign floating IP for external access"
  type        = bool
  default     = false
}

variable "external_network_name" {
  description = "Name of the external network for floating IPs"
  type        = string
  default     = "public"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}