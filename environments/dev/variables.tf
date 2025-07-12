variable "aws_region" {
  type    = string
  default = "ca-central-1"
}

variable "stage" {
  type    = string
  default = "dev"
}

variable "servicename" {
  type    = string
  default = "test"
}

variable "tags" {
  type = map(string)
  default = {}
}

# VPC 모듈에서 요구하는 변수들
variable "vpc_ip_range" {
  type = string
  default = "10.0.0.0/16"
}


variable "subnet_public_az1" {
  type    = string
  default = "10.0.1.0/24"
}

variable "subnet_public_az2" {
  type    = string
  default = "10.0.2.0/24"
}
variable "subnet_service_az1" {
  type = string
  default = "10.0.3.0/24"
}
variable "subnet_service_az2" {
  type = string
  default = "10.0.4.0/24"
}

variable "subnet_db_az1" {
  type = string
  default = "10.0.5.0/24"
}
variable "subnet_db_az2" {
  type = string
  default = "10.0.6.0/24"
}

variable "az" {
  type = list(string)
  default = ["ca-central-1a", "ca-central-1b"]
}

# Instance 모듈에서 요구하는 변수들
variable "instance_count" {
  type    = number
  default = 2
}

# 모듈 쪽에서 "ec2-iam-role-profile-name"를 요구하면,
# 우리가 사용하기 편한 변수명(아래)과 맵핑해줄 수 있음
# variable "ec2_iam_role_profile_name" {
#   type    = string
#   default = "my-ec2-profile"
# }

# 만약 모듈에 "ami" "instance_type" "kms_key_id" 등 있으면 맞춰줍니다
variable "ami" {
  type    = string
  default = "ami-055943271915205db"
}


variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "sg_ec2_ids" {
  type    = list(string)
  default = []
}

variable "subnet_id" {
  type    = string
  default = ""  # 이 값은 VPC 모듈 출력에서 동적으로 설정해야 함
}

variable "ssh_allow_comm_list" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}


variable "kms_key_id" {
  type    = string
  default = ""
}

# ALB 모듈 관련
variable "alb_port" {
  type    = number
  default = 80
}

variable "sg_allow_comm_list" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "vpc_id" {
  type    = string
  default = ""  # 이 값은 VPC 모듈 출력에서 동적으로 설정해야 함
}

variable "certificate_arn" {
  type    = string
  default = ""
}

variable "aws_s3_lb_logs_name" {
  type    = string
  default = ""
}

variable "instance_ids" {
  type    = list(string)
  default = []  # 이 값은 인스턴스 모듈 출력에서 동적으로 설정해야 함
}
# etc...

variable "internal" {
    type  = bool
    default = false
}

# openvpn 모듈 관련
variable "openvpn_allowed_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]  # 자신의 IP 혹은 허용할 범위
}

variable "openvpn_ami_id" {
  type    = string
  default = "ami-0a14a0a5716389b2d"  # OpenVPN Access Server AMI ID
}

variable "openvpn_instance_type" {
  type    = string
  default = "t2.medium"
}

# variable "cluster_name" {
#   type    = string
#   default = "my-cluster"
# }

# eks 모듈 관련
# 네트워킹 관련 변수
variable "sg_eks_cluster_ingress_list" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

# KMS 관련 변수
variable "s3_kms_key_id" {
  type    = string
  default = ""
}

variable "disk_kms_key_id" {
  type    = string
  default = ""
}

variable "rds_data_kms_arn" {
  type    = string
  default = ""
}

variable "sqs_kms_arn" {
  type    = string
  default = ""
}

variable "eks_kms_key_id" {
  type    = string
  default = ""
}

# 그 외 필요한 변수
variable "smoke_test_repository_arn" {
  type    = string
  default = ""
}

# EKS Node Group 스케일링
variable "desired_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 2
}

# EKS Node Group EC2 설정
variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}


variable "sg_allow_comm_ing" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}


variable "ecr_repository_list" {
  type        = list(string)
  description = "생성할 ECR 리포지터리 이름 리스트"
  default     = ["backend"]
}

variable "ecr_allow_account_arns" {
  type        = list(string)
  description = "ECR에서 이미지 Pull을 허용할 IAM ARN 목록"
  default     = ["arn:aws:iam::971422701599:root"]
}

variable "image_tag_mutability" {
  type        = string
  default     = "IMMUTABLE"
}

variable "image_scan_on_push" {
  type    = bool
  default = true
}

variable "helm_repository" {
  type    = string
  default = "helm"  # 예시
}

variable "isdev" {
  type    = bool
  default = true
}

variable "bucket_name" {
  type  = string
  default = "frontend"
}

variable "logging_bucket_id" {
  description = "CloudFront 로깅용 S3 버킷 ID"
  type        = string
  default     = ""
}

variable "acmcertificatearn" {
  description = "CloudFront에서 사용할 ACM 인증서 ARN (없으면 빈 문자열)"
  type        = string
  default     = ""
}

variable "domain" {
  description = "기본 도메인 (예: example.com)"
  type        = string
  default     = ""
}

variable "domain_3rd" {
  description = "서브도메인 (예: www)"
  type        = string
  default     = ""
}

variable "cors_configs" {
  description = "S3 버킷에 적용할 CORS 설정 (없으면 null)"
  type        = any
  default     = null
}

variable "kms_arn" {
  description = "사용할 고객 관리형 KMS 키 ARN (사용하지 않으면 빈 문자열)"
  type        = string
  default     = ""
}


#db관련 변수

variable "dbname" {
  type    = string
  default = "testdb"
}

variable "engine" {
  type    = string
  default = "aurora-mysql"
}

variable "engine_version" {
  type    = string
  default = "8.0.mysql_aurora.3.04.0"
}

variable "master_username" {
  type    = string
  default = "admin"
}

variable "backup_retention_period" {
  type    = string
  default = "7"
}

variable "backup_window" {
  type    = string
  default = "00:00-01:00"
}

# variable "enabled_cloudwatch_logs_exports" {
#   type    = list(string)
#   default = ["audit", "error", "general", "slowquery"]
# }

# variable "max_connections" {
#   type    = string
#   default = "1000"
# }

# variable "max_user_connections" {
#   type    = string
#   default = "1000"
# }

# variable "seconds_util_auto_pause" {
#   type    = string
#   default = "10800"
# }

# variable "timeout_action" {
#   type    = string
#   default = "ForceApplyCapacityChange"
# }

# variable "family" {
#   type    = string
#   default = "aurora-mysql8.0"
# }

# variable "port" {
#   type    = string
#   default = "3306"
# }

variable "sg_allow_ingress_list_aurora" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "sg_allow_ingress_sg_list_aurora" {
  type    = list(string)
  default = []
}

variable "rds_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "rds_instance_auto_minor_version_upgrade" {
  type    = bool
  default = false
}

variable "rds_instance_publicly_accessible" {
  type    = bool
  default = false
}