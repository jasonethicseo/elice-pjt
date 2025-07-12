# MinIO Object Storage Module
# S3 호환 객체 스토리지를 Kubernetes 클러스터에 배포

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# MinIO 네임스페이스 생성
resource "kubernetes_namespace" "minio" {
  metadata {
    name = "${var.servicename}-minio-${var.stage}"
    labels = {
      name = "${var.servicename}-minio-${var.stage}"
    }
  }
}

# MinIO 시크릿 생성
resource "kubernetes_secret" "minio_credentials" {
  metadata {
    name      = "minio-credentials"
    namespace = kubernetes_namespace.minio.metadata[0].name
  }
  
  data = {
    root-user     = var.minio_root_user
    root-password = var.minio_root_password
  }
  
  type = "Opaque"
}

# MinIO PVC 생성
resource "kubernetes_persistent_volume_claim" "minio_storage" {
  count = var.minio_replicas
  
  metadata {
    name      = "minio-storage-${count.index}"
    namespace = kubernetes_namespace.minio.metadata[0].name
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.minio_storage_size
      }
    }
    storage_class_name = "gp2"
  }
}

# MinIO Deployment (단순화)
resource "kubernetes_deployment" "minio" {
  metadata {
    name      = "minio"
    namespace = kubernetes_namespace.minio.metadata[0].name
    labels = {
      app = "minio"
    }
  }
  
  spec {
    replicas = var.minio_replicas
    
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
          name  = "minio"
          image = "minio/minio:${var.minio_image_tag}"
          
          command = [
            "/bin/bash",
            "-c",
            "minio server /data --console-address :9001"
          ]
          
          port {
            container_port = 9000
            name          = "api"
          }
          
          port {
            container_port = 9001
            name          = "console"
          }
          
          env {
            name = "MINIO_ROOT_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.minio_credentials.metadata[0].name
                key  = "root-user"
              }
            }
          }
          
          env {
            name = "MINIO_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.minio_credentials.metadata[0].name
                key  = "root-password"
              }
            }
          }
          
          env {
            name  = "MINIO_PROMETHEUS_AUTH_TYPE"
            value = "public"
          }
          
          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
          
          # Health checks
          liveness_probe {
            http_get {
              path = "/minio/health/live"
              port = 9000
            }
            initial_delay_seconds = 30
            period_seconds        = 20
          }
          
          readiness_probe {
            http_get {
              path = "/minio/health/ready"
              port = 9000
            }
            initial_delay_seconds = 30
            period_seconds        = 20
          }
          
          resources {
            requests = {
              cpu    = var.minio_cpu_request
              memory = var.minio_memory_request
            }
            limits = {
              cpu    = var.minio_cpu_limit
              memory = var.minio_memory_limit
            }
          }
        }
        
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.minio_storage[0].metadata[0].name
          }
        }
      }
    }
  }
  
  depends_on = [kubernetes_persistent_volume_claim.minio_storage]
}

# MinIO API Service
resource "kubernetes_service" "minio_api" {
  metadata {
    name      = "minio-api"
    namespace = kubernetes_namespace.minio.metadata[0].name
    labels = {
      app = "minio"
    }
  }
  
  spec {
    type = "ClusterIP"
    
    selector = {
      app = "minio"
    }
    
    port {
      name        = "api"
      port        = 9000
      target_port = 9000
      protocol    = "TCP"
    }
  }
}

# MinIO Console Service
resource "kubernetes_service" "minio_console" {
  metadata {
    name      = "minio-console"
    namespace = kubernetes_namespace.minio.metadata[0].name
    labels = {
      app = "minio"
    }
  }
  
  spec {
    type = "ClusterIP"
    
    selector = {
      app = "minio"
    }
    
    port {
      name        = "console"
      port        = 9001
      target_port = 9001
      protocol    = "TCP"
    }
  }
}

# MinIO External Service (LoadBalancer) - 선택적
resource "kubernetes_service" "minio_external" {
  count = var.enable_external_access ? 1 : 0
  
  metadata {
    name      = "minio-external"
    namespace = kubernetes_namespace.minio.metadata[0].name
    labels = {
      app = "minio"
    }
  }
  
  spec {
    type = "LoadBalancer"
    
    selector = {
      app = "minio"
    }
    
    port {
      name        = "api"
      port        = 9000
      target_port = 9000
      protocol    = "TCP"
    }
    
    port {
      name        = "console"
      port        = 9001
      target_port = 9001
      protocol    = "TCP"
    }
  }
}

# 기본 버킷 생성을 위한 ConfigMap
resource "kubernetes_config_map" "minio_bucket_script" {
  metadata {
    name      = "minio-bucket-script"
    namespace = kubernetes_namespace.minio.metadata[0].name
  }
  
  data = {
    "create-buckets.sh" = <<-EOF
      #!/bin/bash
      set -e
      
      # MinIO 서버가 준비될 때까지 대기
      until mc alias set minio http://minio-api:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD; do
        echo "Waiting for MinIO server..."
        sleep 5
      done
      
      # 기본 버킷 생성
      ${join("\n", [for bucket in var.default_buckets : "mc mb minio/${bucket} --ignore-existing || true"])}
      
      echo "Bucket creation completed"
    EOF
  }
}

# 버킷 생성 Job
resource "kubernetes_job" "minio_bucket_creation" {
  metadata {
    name      = "minio-bucket-creation"
    namespace = kubernetes_namespace.minio.metadata[0].name
  }
  
  spec {
    template {
      metadata {
        labels = {
          app = "minio-bucket-creator"
        }
      }
      
      spec {
        restart_policy = "Never"
        
        container {
          name  = "mc"
          image = "minio/mc:latest"
          
          command = ["/bin/bash", "/scripts/create-buckets.sh"]
          
          env {
            name = "MINIO_ROOT_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.minio_credentials.metadata[0].name
                key  = "root-user"
              }
            }
          }
          
          env {
            name = "MINIO_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.minio_credentials.metadata[0].name
                key  = "root-password"
              }
            }
          }
          
          volume_mount {
            name       = "scripts"
            mount_path = "/scripts"
          }
        }
        
        volume {
          name = "scripts"
          config_map {
            name = kubernetes_config_map.minio_bucket_script.metadata[0].name
            default_mode = "0755"
          }
        }
      }
    }
  }
  
  depends_on = [kubernetes_service.minio_api, kubernetes_deployment.minio]
}