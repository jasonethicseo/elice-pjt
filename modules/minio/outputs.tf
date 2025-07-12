output "namespace" {
  description = "MinIO namespace"
  value       = kubernetes_namespace.minio.metadata[0].name
}

output "service_name" {
  description = "MinIO API service name"
  value       = kubernetes_service.minio_api.metadata[0].name
}

output "console_service_name" {
  description = "MinIO console service name"
  value       = kubernetes_service.minio_console.metadata[0].name
}

output "endpoint" {
  description = "MinIO API endpoint"
  value       = "http://${kubernetes_service.minio_api.metadata[0].name}.${kubernetes_namespace.minio.metadata[0].name}.svc.cluster.local:9000"
}

output "console_endpoint" {
  description = "MinIO console endpoint"
  value       = "http://${kubernetes_service.minio_console.metadata[0].name}.${kubernetes_namespace.minio.metadata[0].name}.svc.cluster.local:9001"
}

output "external_api_endpoint" {
  description = "MinIO external API endpoint (LoadBalancer)"
  value       = var.enable_external_access ? try(kubernetes_service.minio_external[0].status[0].load_balancer[0].ingress[0].hostname, null) : null
}

output "external_console_endpoint" {
  description = "MinIO external console endpoint (LoadBalancer)"
  value       = var.enable_external_access ? try(kubernetes_service.minio_external[0].status[0].load_balancer[0].ingress[0].hostname, null) : null
}

output "secret_name" {
  description = "MinIO credentials secret name"
  value       = kubernetes_secret.minio_credentials.metadata[0].name
}

output "default_buckets" {
  description = "Default buckets created"
  value       = var.default_buckets
}