terraform {
  required_version = ">= 1.0.0, < 2.0.0"
  backend "s3" {
    bucket         = "jasonseo-dev-terraform-state"
    key            = "terraform/dev/domain-product/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "jasonseo-dev-terraform-lock"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Get core infrastructure outputs
data "terraform_remote_state" "core_infra" {
  backend = "s3"
  config = {
    bucket = "jasonseo-dev-terraform-state"
    key    = "terraform/dev/core-infra/terraform.tfstate"
    region = "ca-central-1"
  }
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
  subnet_ids              = data.terraform_remote_state.core_infra.outputs.db_subnet_ids
  network_vpc_id          = data.terraform_remote_state.core_infra.outputs.vpc_id
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