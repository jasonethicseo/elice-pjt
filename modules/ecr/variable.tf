##Comm (all required)
variable "stage"{
  type = string
}
variable "servicename" {
  type =string
}
variable "tags" {
  type =map(string)
}

##ecr
variable "ecr_repository_list" {
  type        = list(string)
  description = "Name of the ECR"
}

variable "helm_repository" {
  type = string
}
variable "isdev" {
  type = bool
  default = false
}
variable "ecr_allow_account_arns" {
  type        = list(string)
  description = "Allow account to ECR pull"
}

variable "image_tag_mutability" {
  type        = string
  default     = "IMMUTABLE"
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE. Defaults to MUTABLE."
}

variable "image_scan_on_push" {
  default     = true
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false). Defaults to true."
}

