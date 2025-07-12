variable "s3_bucket_domain" {
  description = "S3 버킷의 Regional Domain Name"
  type        = string
}

variable "s3_bucket_id" {
  description = "S3 버킷 ID"
  type        = string
}

variable "default_root_object" {
  description = "기본 루트 객체 (예: index.html)"
  type        = string
  default     = "index.html"
}

variable "min_ttl" {
  description = "최소 TTL (초)"
  type        = number
  default     = 60
}

variable "default_ttl" {
  description = "기본 TTL (초)"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "최대 TTL (초)"
  type        = number
  default     = 86400
}

variable "price_class" {
  description = "CloudFront 배포의 가격 클래스"
  type        = string
  default     = "PriceClass_100"
}

variable "tags" {
  description = "태그 맵"
  type        = map(string)
}

variable "logging_bucket_id" {
  type = string
  default = ""
}