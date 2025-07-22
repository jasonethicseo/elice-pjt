terraform {
  required_version = ">= 1.0.0, < 2.0.0"
  backend "s3" {
    bucket         = "jasonseo-staging-terraform-state"
    key            = "terraform/staging/core-infra/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "jasonseo-staging-terraform-lock"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# 공통 태그 정의
locals {
  common_tags = {
    Environment = var.stage
    ServiceName = var.servicename
    ManagedBy   = "Terraform"
    Component   = "CoreInfra"
  }
}

# VPC 모듈 - 모든 도메인이 공유
module "vpc" {
  source          = "../../../modules/vpc"
  stage           = var.stage
  servicename     = var.servicename
  tags            = merge(local.common_tags, var.tags)

  vpc_ip_range       = var.vpc_ip_range
  subnet_public_az1  = var.subnet_public_az1
  subnet_public_az2  = var.subnet_public_az2
  subnet_service_az1 = var.subnet_service_az1
  subnet_service_az2 = var.subnet_service_az2
  subnet_db_az1      = var.subnet_db_az1
  subnet_db_az2      = var.subnet_db_az2
  az                 = var.az
}

# EKS 클러스터 - 모든 마이크로서비스가 공유
module "eks" {
  source = "../../../modules/eks"

  # 공통/필수 변수
  region      = var.aws_region
  stage       = var.stage
  servicename = var.servicename

  # 네트워킹
  network_vpc_id              = module.vpc.vpc_id
  subnet_ids                  = module.vpc.service_subnet_ids
  sg_eks_cluster_ingress_list = var.sg_eks_cluster_ingress_list
  sg_allow_comm_ing          = var.sg_allow_comm_ing

  # KMS 관련 변수
  s3_kms_key_id    = var.s3_kms_key_id
  disk_kms_key_id  = var.disk_kms_key_id
  rds_data_kms_arn = var.rds_data_kms_arn
  sqs_kms_arn      = var.sqs_kms_arn
  eks_kms_key_id   = var.eks_kms_key_id

  smoke_test_repository_arn = var.smoke_test_repository_arn

  # Node Group 스케일링 - Staging은 더 작은 크기
  desired_size   = var.desired_size
  min_size       = var.min_size
  max_size       = var.max_size
  capacity_type  = "ON_DEMAND"
  instance_types = var.instance_types

  tags = merge(local.common_tags, var.tags)
}

# OpenVPN - 관리 및 개발팀 접근용
module "openvpn" {
  source              = "../../../modules/openvpn"
  stage               = var.stage
  servicename         = var.servicename
  allowed_cidr_blocks = var.openvpn_allowed_cidr_blocks
  vpc_id              = module.vpc.vpc_id
  ami_id              = var.openvpn_ami_id
  instance_type       = var.openvpn_instance_type
  subnet_id           = module.vpc.public_subnet_ids[0]
  tags                = merge(local.common_tags, var.tags)
}

# 공유 S3 버킷 - static assets 등
module "s3_static" {
  source = "../../../modules/s3"

  bucket_name       = var.bucket_name
  servicename       = var.servicename
  stage             = var.stage
  tags              = merge(local.common_tags, var.tags)

  ispub                     = true
  isCFN                     = true
  islog                     = true
  logging_bucket_id         = var.logging_bucket_id
  acmcertificatearn        = var.acmcertificatearn
  domain                   = var.domain
  domain_3rd               = var.domain_3rd

  versioning_enabled       = "true"
  lifecycle_rule_enabled   = "true"

  STANDARD_IA_Transition_days = "90"
  GLACIER_Transition_days     = "1825"
  expiration_days             = "3650"
  
  cors_configs = var.cors_configs
  kms_arn      = var.kms_arn
}

# CloudFront - 공유 CDN
module "cloudfront_cdn" {
  source = "../../../modules/cloudfront"

  s3_bucket_domain    = module.s3_static.bucket_regional_domain_name
  s3_bucket_id        = module.s3_static.bucket_name
  default_root_object = "index.html"
  min_ttl             = 60
  default_ttl         = 3600
  max_ttl             = 86400
  price_class         = "PriceClass_100"
  tags                = merge(local.common_tags, var.tags)
}

# MinIO Object Storage for S3-compatible storage
module "minio" {
  source = "../../../modules/minio"

  stage           = var.stage
  servicename     = var.servicename
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.service_subnet_ids
  
  # MinIO 설정
  minio_root_user     = var.minio_root_user
  minio_root_password = var.minio_root_password
  minio_storage_size  = var.minio_storage_size
  
  tags = merge(local.common_tags, var.tags)
}