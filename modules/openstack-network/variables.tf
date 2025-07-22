variable "stage" {
  description = "Environment stage (dev, staging, production)"
  type        = string
}

variable "servicename" {
  description = "Service name"
  type        = string
}

variable "vpc_ip_range" {
  description = "CIDR block for the private network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "external_network_id" {
  description = "External network ID for internet access"
  type        = string
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}