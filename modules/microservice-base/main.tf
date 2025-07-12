# Microservice base module - 각 도메인에서 공통으로 사용하는 리소스

# ECR Repository for domain services
resource "aws_ecr_repository" "service_repo" {
  for_each = toset(var.service_names)
  
  name                 = "${var.domain}-${each.value}-${var.stage}"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.image_scan_on_push
  }

  lifecycle_policy {
    policy = jsonencode({
      rules = [
        {
          rulePriority = 1
          description  = "Keep last 10 production images"
          selection = {
            tagStatus     = "tagged"
            tagPrefixList = ["prod"]
            countType     = "imageCountMoreThan"
            countNumber   = 10
          }
          action = {
            type = "expire"
          }
        },
        {
          rulePriority = 2
          description  = "Keep last 5 development images"
          selection = {
            tagStatus   = "untagged"
            countType   = "imageCountMoreThan"
            countNumber = 5
          }
          action = {
            type = "expire"
          }
        }
      ]
    })
  }

  tags = merge(var.tags, {
    Domain  = var.domain
    Service = "all"
  })
}

# Kubernetes namespace for the domain
resource "kubernetes_namespace" "domain_namespace" {
  metadata {
    name = var.domain
    labels = {
      "name"                               = var.domain
      "istio-injection"                   = "enabled"
      "pod-security.kubernetes.io/enforce" = "baseline"
      "environment"                       = var.stage
    }
    annotations = {
      "scheduler.alpha.kubernetes.io/node-selector" = "workload-type=microservices"
    }
  }
}

# Service account for the domain
resource "kubernetes_service_account" "domain_service_account" {
  metadata {
    name      = "${var.domain}-service-account"
    namespace = kubernetes_namespace.domain_namespace.metadata[0].name
    labels = {
      "app.kubernetes.io/name"     = "${var.domain}-service-account"
      "app.kubernetes.io/part-of"  = var.domain
      "environment"                = var.stage
    }
  }

  automount_service_account_token = true
}

# Network policy for the domain namespace
resource "kubernetes_network_policy" "domain_network_policy" {
  metadata {
    name      = "${var.domain}-network-policy"
    namespace = kubernetes_namespace.domain_namespace.metadata[0].name
  }

  spec {
    pod_selector {}
    
    policy_types = ["Ingress", "Egress"]
    
    # Allow ingress from ingress controller
    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "ingress-nginx"
          }
        }
      }
    }
    
    # Allow ingress from same namespace
    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = var.domain
          }
        }
      }
    }
    
    # Allow egress to same namespace
    egress {
      to {
        namespace_selector {
          match_labels = {
            name = var.domain
          }
        }
      }
    }
    
    # Allow egress to database subnets
    egress {
      ports {
        protocol = "TCP"
        port     = "5432"
      }
    }
    
    # Allow egress to DNS
    egress {
      to {}
      ports {
        protocol = "UDP"
        port     = "53"
      }
    }
    
    # Allow egress to HTTPS
    egress {
      to {}
      ports {
        protocol = "TCP"
        port     = "443"
      }
    }
  }
}

# Resource quota for the domain namespace
resource "kubernetes_resource_quota" "domain_resource_quota" {
  metadata {
    name      = "${var.domain}-resource-quota"
    namespace = kubernetes_namespace.domain_namespace.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"    = var.resource_quota.requests_cpu
      "requests.memory" = var.resource_quota.requests_memory
      "limits.cpu"      = var.resource_quota.limits_cpu
      "limits.memory"   = var.resource_quota.limits_memory
      "pods"            = var.resource_quota.pods
      "services"        = var.resource_quota.services
      "persistentvolumeclaims" = var.resource_quota.pvcs
    }
  }
}