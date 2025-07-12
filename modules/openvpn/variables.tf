variable "stage" {
  description = "배포 단계 (예: dev, prod)"
  type        = string
}

variable "servicename" {
  description = "서비스 이름"
  type        = string
}

variable "tags" {
  description = "추가 태그"
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "인스턴스를 배치할 퍼블릭 서브넷 ID"
  type        = string
}

variable "ami_id" {
  description = "OpenVPN 인스턴스에 사용할 AMI ID (예: Marketplace의 OpenVPN Access Server AMI)"
  type        = string
}

variable "instance_type" {
  description = "OpenVPN 인스턴스의 EC2 인스턴스 타입"
  type        = string
  default     = "t3.medium"
}

variable "allowed_cidr_blocks" {
  description = "OpenVPN 인스턴스에 접근을 허용할 CIDR 블록 리스트 (예: 자신의 IP)"
  type        = list(string)
}

variable "cluster_name" {
  description = "필요 시 전달할 클러스터명 (user_data에서 활용 가능)"
  type        = string
  default     = ""
}

variable "ebs_size" {
  type = number
  default = 30
}