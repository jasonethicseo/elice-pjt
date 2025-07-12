variable "domain" {
  description = "Domain name for the microservice (e.g., order, product, user)"
  type        = string
}

variable "stage" {
  description = "Environment stage (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "service_names" {
  description = "List of service names within the domain"
  type        = list(string)
  default     = ["api", "worker"]
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting for ECR repository"
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "image_scan_on_push" {
  description = "Enable image scanning on push to ECR"
  type        = bool
  default     = true
}

variable "resource_quota" {
  description = "Resource quota settings for the domain namespace"
  type = object({
    requests_cpu    = string
    requests_memory = string
    limits_cpu      = string
    limits_memory   = string
    pods            = string
    services        = string
    pvcs            = string
  })
  default = {
    requests_cpu    = "2"
    requests_memory = "4Gi"
    limits_cpu      = "4"
    limits_memory   = "8Gi"
    pods            = "20"
    services        = "10"
    pvcs            = "5"
  }
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}