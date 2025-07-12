terraform {
  required_version = ">= 1.0.0, < 2.0.0"
  backend "s3" {
    bucket         = "jasonseo-dev-terraform-state"
    key            = "terraform/dev/domain-user/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "jasonseo-dev-terraform-lock"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Get core infrastructure outputs (conditionally)
data "terraform_remote_state" "core_infra" {
  count = var.mock_mode ? 0 : 1
  
  backend = "s3"
  config = {
    bucket = "jasonseo-dev-terraform-state"
    key    = "terraform/dev/core-infra/terraform.tfstate"
    region = "ca-central-1"
  }
}

# Local values that use either real or mock data
locals {
  vpc_id             = var.mock_mode ? var.mock_vpc_id : data.terraform_remote_state.core_infra[0].outputs.vpc_id
  db_subnet_ids      = var.mock_mode ? var.mock_db_subnet_ids : data.terraform_remote_state.core_infra[0].outputs.db_subnet_ids
  service_subnet_ids = var.mock_mode ? var.mock_service_subnet_ids : data.terraform_remote_state.core_infra[0].outputs.service_subnet_ids
  eks_cluster_name   = var.mock_mode ? var.mock_eks_cluster_name : data.terraform_remote_state.core_infra[0].outputs.eks_cluster_name
}

locals {
  common_tags = {
    Environment = var.stage
    ServiceName = var.servicename
    Domain      = "user"
    ManagedBy   = "Terraform"
  }
}

# Microservice base resources (ECR, Namespace, etc.)
module "user_microservice_base" {
  source = "../../../modules/microservice-base"

  domain        = "user"
  stage         = var.stage
  service_names = ["api", "auth", "profile", "notification"]

  image_tag_mutability = var.image_tag_mutability
  image_scan_on_push   = var.image_scan_on_push

  resource_quota = {
    requests_cpu    = "1"
    requests_memory = "2Gi"
    limits_cpu      = "2"
    limits_memory   = "4Gi"
    pods            = "12"
    services        = "6"
    pvcs            = "2"
  }

  tags = merge(local.common_tags, var.tags)
}

# PostgreSQL database for user domain
module "user_aurora" {
  source      = "../../../modules/aurora"
  stage       = var.stage
  servicename = "${var.servicename}-user"
  tags        = merge(local.common_tags, var.tags)

  # DB 구성
  dbname                  = "userdb"
  engine                  = "aurora-postgresql"
  engine_version          = "15.4"
  master_username         = var.master_username
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  kms_key_id              = var.kms_key_id

  # 네트워크 구성 (core-infra에서 가져옴)
  az                      = var.az
  subnet_ids              = local.db_subnet_ids
  network_vpc_id          = local.vpc_id
  sg_allow_ingress_list_aurora = var.sg_allow_ingress_list_aurora
  sg_allow_ingress_sg_list_aurora = var.sg_allow_ingress_sg_list_aurora

  # RDS 인스턴스 설정
  rds_instance_count                   = 2
  rds_instance_class                   = var.rds_instance_class
  rds_instance_auto_minor_version_upgrade = var.rds_instance_auto_minor_version_upgrade
  rds_instance_publicly_accessible        = var.rds_instance_publicly_accessible
}

# User domain specific S3 bucket (for user profiles, avatars, etc.)
module "user_s3" {
  source = "../../../modules/s3"

  bucket_name = "${var.servicename}-user-profiles-${var.stage}"
  servicename = var.servicename
  stage       = var.stage
  tags        = merge(local.common_tags, var.tags)

  ispub  = false  # Private bucket with signed URLs
  isCFN  = false
  islog  = false
  logging_bucket_id = ""
  
  versioning_enabled     = "true"
  lifecycle_rule_enabled = "true"

  STANDARD_IA_Transition_days = "180"
  GLACIER_Transition_days     = "730"
  expiration_days             = "2555"  # 7 years for compliance

  cors_configs = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT", "POST"]
      allowed_origins = ["https://*.${var.domain_name}"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]
  kms_arn = var.kms_arn
}

##임시