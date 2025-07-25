terraform {
  required_version = ">= 1.0.0, < 2.0.0"
  backend "s3" {
    bucket         = "jasonseo-staging-terraform-state"
    key            = "terraform/staging/domain-product/terraform.tfstate"
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
    Domain      = "product"
    ManagedBy   = "Terraform"
  }
}

# Microservice base resources (ECR, Namespace, etc.)
module "product_microservice_base" {
  source = "../../../modules/microservice-base"

  domain        = "product"
  stage         = var.stage
  service_names = ["api", "search", "recommendation", "inventory"]

  image_tag_mutability = var.image_tag_mutability
  image_scan_on_push   = var.image_scan_on_push

  resource_quota = {
    requests_cpu    = "1.5"
    requests_memory = "3Gi"
    limits_cpu      = "3"
    limits_memory   = "6Gi"
    pods            = "20"
    services        = "10"
    pvcs            = "5"
  }

  tags = merge(local.common_tags, var.tags)
}

# PostgreSQL database for product domain
module "product_aurora" {
  source      = "../../../modules/aurora"
  stage       = var.stage
  servicename = "${var.servicename}-product"
  tags        = merge(local.common_tags, var.tags)

  # DB 구성
  dbname                  = "productdb"
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

# Product domain specific S3 bucket (for product images, catalogs, etc.)
module "product_s3" {
  source = "../../../modules/s3"

  bucket_name = "${var.servicename}-product-assets-${var.stage}"
  servicename = var.servicename
  stage       = var.stage
  tags        = merge(local.common_tags, var.tags)

  ispub  = true   # Public for product images
  isCFN  = true   # CloudFront integration
  islog  = false
  logging_bucket_id = ""
  
  versioning_enabled     = "true"
  lifecycle_rule_enabled = "true"

  STANDARD_IA_Transition_days = "90"
  GLACIER_Transition_days     = "365"
  expiration_days             = "1095"  # 3 years

  cors_configs = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]
  kms_arn = var.kms_arn
}

# Helm Chart ECR Repository for product domain
module "product_helm_repo" {
  source = "../../../modules/ecr"

  stage       = var.stage
  servicename = var.servicename
  tags        = merge(local.common_tags, var.tags)

  ecr_repository_list = [] # No regular image repos here
  helm_repository     = "helm-charts-product" # Unique name for the helm repo
  isdev               = false # Disable for staging environment
  ecr_allow_account_arns = var.ecr_allow_account_arns

  image_tag_mutability = var.image_tag_mutability
  image_scan_on_push   = var.image_scan_on_push
}