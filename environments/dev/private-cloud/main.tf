# Development Environment - Private Cloud (OpenStack)
# 프라이빗 클라우드 개발 환경 구성

terraform {
  required_version = ">= 1.8.0"
  
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    bucket         = "jasonseo-dev-terraform-state"
    key            = "private-cloud/dev/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "jasonseo-dev-terraform-lock"
    encrypt        = true
  }
}

# OpenStack Provider Configuration
provider "openstack" {
  auth_url    = var.openstack_auth_url
  tenant_name = var.openstack_tenant_name
  user_name   = var.openstack_user_name
  password    = var.openstack_password
  region      = var.openstack_region
}

# Local Variables
locals {
  stage = "dev"
  servicename = "microservices"
  
  common_tags = {
    Environment   = local.stage
    Project       = "elice-pjt"
    ManagedBy     = "terraform"
    Owner         = "DevOps"
    CloudType     = "private"
    Platform      = "openstack"
  }
}

# Network Module
module "network" {
  source = "../../../modules/openstack-network"
  
  stage                   = local.stage
  servicename            = local.servicename
  vpc_ip_range           = var.vpc_ip_range
  external_network_id    = var.external_network_id
  dns_nameservers        = var.dns_nameservers
  allocation_pool_start  = var.allocation_pool_start
  allocation_pool_end    = var.allocation_pool_end
  
  tags = local.common_tags
}

# Storage Module
module "storage" {
  source = "../../../modules/openstack-storage"
  
  stage                    = local.stage
  servicename             = local.servicename
  master_count            = var.master_count
  worker_count            = var.worker_count
  database_count          = var.database_count
  object_storage_node_count = var.object_storage_node_count
  shared_storage_count    = var.shared_storage_count
  
  # Volume Sizes (Development - smaller sizes)
  etcd_volume_size              = 10
  worker_volume_size           = 50
  database_volume_size         = 100
  database_backup_volume_size  = 200
  object_storage_volume_size   = 500
  shared_storage_volume_size   = 25
  
  enable_swift_storage = var.enable_swift_storage
  enable_backups      = false  # Disable backups for dev
  
  tags = local.common_tags
}

# Compute Module
module "compute" {
  source = "../../../modules/openstack-compute"
  
  stage                    = local.stage
  servicename             = local.servicename
  network_name            = module.network.private_network_name
  k8s_security_group_name = module.network.k8s_security_group_name
  db_security_group_name  = module.network.db_security_group_name
  
  # Instance Counts (Development)
  master_count   = var.master_count
  worker_count   = var.worker_count
  database_count = var.database_count
  
  # Instance Flavors (Development - smaller sizes)
  master_flavor      = "m1.medium"
  worker_flavor      = "m1.large"
  database_flavor    = "m1.medium"
  loadbalancer_flavor = "m1.small"
  
  public_key            = var.public_key
  enable_loadbalancer   = true
  enable_external_access = true  # Allow external access for dev
  external_network_name = var.external_network_name
  
  tags = local.common_tags
  
  depends_on = [module.network, module.storage]
}

# Kubernetes Configuration (using external data source)
data "external" "kubeconfig" {
  program = ["bash", "-c", <<-EOT
    # This would be replaced with actual Kubernetes setup script
    echo '{"status": "ready", "endpoint": "https://${module.compute.loadbalancer_floating_ip}:6443"}'
  EOT
  ]
  
  depends_on = [module.compute]
}

# Create Kubernetes namespaces and basic resources
provider "kubernetes" {
  # This would be configured with the actual cluster endpoint
  # For now, it's a placeholder
  host = "https://${module.compute.loadbalancer_floating_ip != null ? module.compute.loadbalancer_floating_ip : "localhost"}:6443"
  
  # In a real scenario, you would configure authentication here
  # client_certificate     = base64decode(var.client_certificate)
  # client_key             = base64decode(var.client_key)
  # cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

# Microservices Namespaces
resource "kubernetes_namespace" "microservices_user" {
  metadata {
    name = "microservices-user-${local.stage}"
    labels = {
      domain      = "user"
      environment = local.stage
      platform    = "openstack"
    }
  }
}

resource "kubernetes_namespace" "microservices_product" {
  metadata {
    name = "microservices-product-${local.stage}"
    labels = {
      domain      = "product"
      environment = local.stage
      platform    = "openstack"
    }
  }
}

resource "kubernetes_namespace" "microservices_order" {
  metadata {
    name = "microservices-order-${local.stage}"
    labels = {
      domain      = "order"
      environment = local.stage
      platform    = "openstack"
    }
  }
}

# MinIO Object Storage Namespace
resource "kubernetes_namespace" "microservices_minio" {
  metadata {
    name = "microservices-minio-${local.stage}"
    labels = {
      component   = "storage"
      environment = local.stage
      platform    = "openstack"
    }
  }
}

# Basic MinIO Deployment (using Swift backend)
resource "kubernetes_deployment" "minio" {
  metadata {
    name      = "minio"
    namespace = kubernetes_namespace.microservices_minio.metadata[0].name
    labels = {
      app = "minio"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "minio"
      }
    }

    template {
      metadata {
        labels = {
          app = "minio"
        }
      }

      spec {
        container {
          image = "minio/minio:latest"
          name  = "minio"
          
          command = ["/bin/bash", "-c"]
          args = ["minio server /data --console-address :9001"]

          port {
            container_port = 9000
          }
          
          port {
            container_port = 9001
          }

          env {
            name  = "MINIO_ROOT_USER"
            value = "minioadmin"
          }
          
          env {
            name  = "MINIO_ROOT_PASSWORD"
            value = "minioadmin123"
          }

          volume_mount {
            name       = "storage"
            mount_path = "/data"
          }
        }

        volume {
          name = "storage"
          empty_dir {}
        }
      }
    }
  }
}

# MinIO Service
resource "kubernetes_service" "minio_api" {
  metadata {
    name      = "minio-api"
    namespace = kubernetes_namespace.microservices_minio.metadata[0].name
  }

  spec {
    selector = {
      app = "minio"
    }

    port {
      name        = "api"
      port        = 9000
      target_port = 9000
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "minio_console" {
  metadata {
    name      = "minio-console"
    namespace = kubernetes_namespace.microservices_minio.metadata[0].name
  }

  spec {
    selector = {
      app = "minio"
    }

    port {
      name        = "console"
      port        = 9001
      target_port = 9001
    }

    type = "LoadBalancer"
  }
}