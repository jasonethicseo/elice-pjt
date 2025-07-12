
variable "bucket_name" {
  type =string
}
variable "kms_arn" {
  type = string
  default = ""
}
variable "servicename" {
  type =string
}
variable "stage" {
  type =string
}
variable "tags" {
  type = map(string)
}
variable "versioning_enabled" {
  type = string
  default = "true"
}
variable "lifecycle_rule_enabled" {
  type = string
  default = "true"
}

variable "STANDARD_IA_Transition_days" {
  type = string
  default = "90" #3M
}
variable "GLACIER_Transition_days" {
  type = string
  default = "1825" #5Y
}
variable "expiration_days" {
  type = string
  default = "3650" #10Y
}

variable "ispub" {
  type = bool
  default = false
}
variable "isCFN" {
  type = bool
  default = false
}

variable "cors_configs" {
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
  default = null
}

variable "logging_bucket_id" {
  type = string
  default = ""
}
variable "waf_acl_id" {
  type = string
  default = ""
}
variable "acmcertificatearn" {
  type = string
  default = ""
}
variable "domain_3rd" {
  type = string
  default = ""
}
variable "islog" {
  type = bool
  default = false
}

variable "domain" {
  type = string
  default = ""
}