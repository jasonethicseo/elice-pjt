terraform {
  required_version = ">= 1.0.0, < 2.0.0"
  backend "s3" {
    bucket         = "jasonseo-staging-terraform-state"
    key            = "terraform/staging/domain-order/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "jasonseo-staging-terraform-lock"
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
    bucket = "jasonseo-staging-terraform-state"
    key    = "terraform/staging/core-infra/terraform.tfstate"
    region = "ca-central-1"
  }
}

# Local values that use either real or mock data (safe with try() fallback)
locals {
  vpc_id             = var.mock_mode ? var.mock_vpc_id : try(data.terraform_remote_state.core_infra[0].outputs.vpc_id, var.mock_vpc_id)
  db_subnet_ids      = var.mock_mode ? var.mock_db_subnet_ids : try(data.terraform_remote_state.core_infra[0].outputs.db_subnet_ids, var.mock_db_subnet_ids)
  service_subnet_ids = var.mock_mode ? var.mock_service_subnet_ids : try(data.terraform_remote_state.core_infra[0].outputs.service_subnet_ids, var.mock_service_subnet_ids)
  eks_cluster_name   = var.mock_mode ? var.mock_eks_cluster_name : try(data.terraform_remote_state.core_infra[0].outputs.eks_cluster_name, var.mock_eks_cluster_name)
}

locals {
  common_tags = {
    Environment = var.stage
    ServiceName = var.servicename
    Domain      = "order"
    ManagedBy   = "Terraform"
  }
}

# Microservice base resources (ECR, Namespace, etc.)
module "order_microservice_base" {
  source = "../../../modules/microservice-base"

  domain        = "order"
  stage         = var.stage
  service_names = ["api", "worker", "scheduler"]

  image_tag_mutability = var.image_tag_mutability
  image_scan_on_push   = var.image_scan_on_push

  resource_quota = {
    requests_cpu    = "1"
    requests_memory = "2Gi"
    limits_cpu      = "2"
    limits_memory   = "4Gi"
    pods            = "15"
    services        = "8"
    pvcs            = "3"
  }

  tags = merge(local.common_tags, var.tags)
}

# PostgreSQL database for order domain
module "order_aurora" {
  source      = "../../../modules/aurora"
  stage       = var.stage
  servicename = "${var.servicename}-order"
  tags        = merge(local.common_tags, var.tags)

  # DB 구성
  dbname                  = "orderdb"
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

# Order domain specific S3 bucket (for order documents, receipts, etc.)
module "order_s3" {
  source = "../../../modules/s3"

  bucket_name = "${var.servicename}-order-documents-${var.stage}"
  servicename = var.servicename
  stage       = var.stage
  tags        = merge(local.common_tags, var.tags)

  ispub  = false  # Private bucket
  isCFN  = false
  islog  = false
  logging_bucket_id = ""
  
  versioning_enabled     = "true"
  lifecycle_rule_enabled = "true"

  STANDARD_IA_Transition_days = "30"
  GLACIER_Transition_days     = "365"
  expiration_days             = "2555"  # 7 years for compliance

  cors_configs = null
  kms_arn      = var.kms_arn
}

# Helm Chart ECR Repository for order domain
module "order_helm_repo" {
  source = "../../../modules/ecr"

  stage       = var.stage
  servicename = var.servicename
  tags        = merge(local.common_tags, var.tags)

  ecr_repository_list = [] # No regular image repos here
  helm_repository     = "helm-charts-order" # Unique name for the helm repo
  isdev               = false # Disable for staging environment
  ecr_allow_account_arns = var.ecr_allow_account_arns

  image_tag_mutability = var.image_tag_mutability
  image_scan_on_push   = var.image_scan_on_push
}