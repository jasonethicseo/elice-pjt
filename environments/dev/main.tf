terraform {
  required_version = ">= 1.0.0, < 2.0.0"
#  만약 S3 backend를 사용하신다면, 아래를 해제하고 적절히 수정
  backend "s3" {
    bucket         = "jasonseo-dev-terraform-state"
    key            = "terraform/dev/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "jasonseo-dev-terraform-lock"
    use_lockfile   = true
    encrypt        = true
    # profile        = "jasonseo"
  }
}

provider "aws" {
  region  = var.aws_region
  # profile = "jasonseo"
}


# 공통 태그 정의 (locals)

locals {
  common_tags = {
    Environment = var.stage
    ServiceName = var.servicename
    ManagedBy   = "Terraform"
  }
}

# 
# # KMS 모듈
# 
# module "kms" {
#   source      = "../../modules/kms"
#   stage       = var.stage
#   servicename = var.servicename

#   tags = merge(local.common_tags, var.tags)
# }


# VPC 모듈

module "vpc" {
  source          = "../../modules/vpc"
  stage           = var.stage
  servicename     = var.servicename
  tags            = merge(local.common_tags, var.tags)

  vpc_ip_range      = var.vpc_ip_range
  subnet_public_az1 = var.subnet_public_az1
  subnet_public_az2 = var.subnet_public_az2
  subnet_service_az1 = var.subnet_service_az1
  subnet_service_az2 = var.subnet_service_az2
  subnet_db_az1     = var.subnet_db_az1
  subnet_db_az2     = var.subnet_db_az2
  az                = var.az
}


# Instance 모듈

# module "instance" {
#   source = "../../modules/instance"
#   stage        = var.stage
#   servicename  = var.servicename
#   tags         = merge(local.common_tags, var.tags)

#   ami           = var.ami
#   instance_type = var.instance_type

#   # 기존에 'module.vpc.service-az1.id' 등을 참조했다면,
#   # 이제는 vpc 모듈의 outputs.tf에서 output "service_subnet_az1_id"로 정의된 이름 사용
#   subnet_id     = module.vpc.service_subnet_az1_id
#   vpc_id        = module.vpc.vpc_id

#   sg_ec2_ids    = var.sg_ec2_ids

#   # 모듈 내부에서 'variable "ec2-iam-role-profile-name"'라고 되어 있다면:
#   # => 루트에서 key는 "ec2-iam-role-profile-name"
#   # ec2_iam_role_profile_name = var.ec2_iam_role_profile_name

#   # kms_key_id    = module.kms.ebs_kms_arn   # 예시로 KMS 모듈의 EKS 키 ARN
#   ssh_allow_comm_list = var.ssh_allow_comm_list

#   # 만약 instance 모듈은 output "instance_id"를 제공 => ALB에서 등록
# }



# ALB 모듈

# module "alb" {
#   source       = "../../modules/alb"
#   stage        = var.stage
#   servicename  = var.servicename
#   tags         = merge(local.common_tags, var.tags)
#   internal     = false
#   # ALB 서브넷. 여기서는 서비스 서브넷 2개라고 가정
#   # => vpc 모듈 output "service_subnet_az1_id", "service_subnet_az2_id"
#   subnet_ids   = [
#     module.vpc.service_subnet_az1_id,
#     module.vpc.service_subnet_az2_id
#   ]

#   vpc_id       = module.vpc.vpc_id
#   # instance_ids => 인스턴스 모듈에서 output "instance_id" or "instance_ids"
#   # 예를 들어 instance 모듈이 output "instance_id" 라고 한다면:
#   instance_ids = [module.instance.instance_id]

#   # certificate_arn    = var.certificate_arn
#   # aws_s3_lb_logs_name= var.aws_s3_lb_logs_name
#   port               = var.alb_port
#   sg_allow_comm_list = var.sg_allow_comm_list

#   depends_on = [module.instance]
# }


module "openvpn" {
  source              = "../../modules/openvpn"         # openvpn 모듈 경로
  stage               = var.stage                       # 예: "dev", "prod"
  servicename         = var.servicename                 # 서비스 이름
  allowed_cidr_blocks = var.openvpn_allowed_cidr_blocks   # 접속 허용 CIDR 블록 리스트 (예: ["203.0.113.0/24"])
  vpc_id              = module.vpc.vpc_id               # VPC 모듈의 출력값
  ami_id              = var.openvpn_ami_id              # OpenVPN Access Server AMI ID
  instance_type       = var.openvpn_instance_type       # 예: "t3.medium"
  subnet_id           = module.vpc.public_subnet_ids[0]   # 퍼블릭 서브넷 중 하나 (예: 첫 번째)
  # cluster_name        = var.cluster_name                # 필요 시 전달 (user_data에서 사용)
  tags                = merge(local.common_tags, var.tags)             # 추가 태그 (또는 var.common_tags와 merge 가능)
}


module "eks" {
  # "eks" 디렉터리가 하나의 모듈 (eks-cluster.tf, eks-nodegroup.tf 등)
  source = "../../modules/eks"

  # 공통/필수 변수
  region      = var.aws_region
  stage       = var.stage
  servicename = var.servicename

  # 네트워킹
  network_vpc_id              = module.vpc.vpc_id
  subnet_ids                  = module.vpc.service_subnet_ids
  sg_eks_cluster_ingress_list = var.sg_eks_cluster_ingress_list
  sg_allow_comm_ing = var.sg_allow_comm_ing

  # KMS 관련 변수
  s3_kms_key_id   = var.s3_kms_key_id
  disk_kms_key_id = var.disk_kms_key_id
  rds_data_kms_arn = var.rds_data_kms_arn
  sqs_kms_arn      = var.sqs_kms_arn
  eks_kms_key_id   = var.eks_kms_key_id

  # 그 외 필요한 변수
  smoke_test_repository_arn = var.smoke_test_repository_arn

  # Node Group 스케일링
  desired_size = var.desired_size
  min_size     = var.min_size
  max_size     = var.max_size
  capacity_type = "ON_DEMAND"
  instance_types = var.instance_types
  # Node Group EC2 설정

  tags                = merge(local.common_tags, var.tags) 
}


module "ecr" {
  source = "../../modules/ecr"  # ECR 모듈 디렉터리 경로

  stage                = var.stage
  servicename          = var.servicename
  tags                 = var.tags
  ecr_repository_list  = var.ecr_repository_list  # 예: ["backend"]
  ecr_allow_account_arns = var.ecr_allow_account_arns
  image_tag_mutability = var.image_tag_mutability
  image_scan_on_push    = var.image_scan_on_push

  helm_repository      = var.helm_repository
  isdev                = var.isdev
}

module "s3_static" {
  source = "../../modules/s3"  # S3 모듈 디렉터리 경로

  bucket_name = var.bucket_name   # 예: "frontend"
  servicename = var.servicename
  stage       = var.stage
  tags        = merge(local.common_tags, var.tags)

  ispub       = true   # 프라이빗 버킷으로 생성 (CloudFront를 통해서만 공개) 임시 퍼블릭
  isCFN       = true    # CloudFront와 연동할 경우 true
  islog       = true    # 로깅 활성화 시 false
  logging_bucket_id = var.logging_bucket_id  # 로깅용 S3 버킷 ID 없으면 var에 빈 문자열
  acmcertificatearn = var.acmcertificatearn   # SSL 인증서 ARN (CloudFront에 필요)
  domain      = var.domain
  domain_3rd  = var.domain_3rd

  versioning_enabled    = "true"
  lifecycle_rule_enabled = "true"

  STANDARD_IA_Transition_days = "90"
  GLACIER_Transition_days      = "1825"
  expiration_days              = "3650"
  
  cors_configs = var.cors_configs  # CORS 설정이 필요한 경우
  kms_arn      = var.kms_arn       # 고객 관리형 KMS 키 사용하지 않을 경우 빈 문자열 ""
}

module "cloudfront_cdn" {
  source = "../../modules/cloudfront"

  s3_bucket_domain = module.s3_static.bucket_regional_domain_name
  s3_bucket_id     = module.s3_static.bucket_name
  default_root_object = "index.html"
  min_ttl = 60
  default_ttl = 3600
  max_ttl = 86400
  price_class = "PriceClass_100"
  tags = merge(local.common_tags, var.tags)
}

module "aurora" {
  source       = "../../modules/aurora"    # Aurora 모듈 경로 (실제 경로에 맞게 수정)
  stage        = var.stage
  servicename  = var.servicename
  tags         = merge(local.common_tags, var.tags)

  # DB 구성 변수
  dbname                  = var.dbname                   # 예: "testdb"
  engine                  = var.engine                   # 예: "aurora-mysql"
  engine_version          = var.engine_version           # 예: "8.0.mysql_aurora.3.01.0"
  master_username         = var.master_username          # 예: "admin"
  backup_retention_period = var.backup_retention_period  # 예: "7"
  backup_window           = var.backup_window            # 예: "00:00-01:00"
  kms_key_id              = var.kms_key_id               # 사용 가능한 KMS 키 ARN
  # enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports  # 예: ["audit", "error", "general", "slowquery"]
  # max_connections         = var.max_connections          # 예: "1000"
  # max_user_connections    = var.max_user_connections     # 예: "1000"
  # seconds_util_auto_pause = var.seconds_util_auto_pause  # 예: "10800"
  # timeout_action          = var.timeout_action           # 예: "ForceApplyCapacityChange"
  # family                  = var.family                   # 예: "aurora-mysql8.0"
  # port                    = var.port                     # 예: "3306"

  # 네트워크 구성
  az                      = var.az                       # 예: ["ca-central-1a", "ca-central-1b"]
  subnet_ids              = module.vpc.db_subnet_ids
  network_vpc_id          = module.vpc.vpc_id           # VPC ID (예: "vpc-xxxxxxx")
  sg_allow_ingress_list_aurora = var.sg_allow_ingress_list_aurora  # CIDR 기반 인바운드 규칙 (예: ["0.0.0.0/0"])
  sg_allow_ingress_sg_list_aurora = var.sg_allow_ingress_sg_list_aurora  # 보안그룹 기반 인바운드 규칙 (빈 리스트 가능)

  # 테스트용으로 RDS 인스턴스는 생성하지 않음.
  rds_instance_count              = 1
  rds_instance_class              = var.rds_instance_class
  rds_instance_auto_minor_version_upgrade = var.rds_instance_auto_minor_version_upgrade
  rds_instance_publicly_accessible        = var.rds_instance_publicly_accessible
}



