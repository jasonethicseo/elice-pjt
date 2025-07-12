output "ecr_repository_urls" {
  description = "URLs of the ECR repositories"
  value = {
    for service_name, repo in aws_ecr_repository.service_repo : service_name => repo.repository_url
  }
}

output "ecr_repository_arns" {
  description = "ARNs of the ECR repositories"
  value = {
    for service_name, repo in aws_ecr_repository.service_repo : service_name => repo.arn
  }
}

output "namespace_name" {
  description = "Name of the Kubernetes namespace"
  value       = kubernetes_namespace.domain_namespace.metadata[0].name
}

output "service_account_name" {
  description = "Name of the Kubernetes service account"
  value       = kubernetes_service_account.domain_service_account.metadata[0].name
}

output "network_policy_name" {
  description = "Name of the Kubernetes network policy"
  value       = kubernetes_network_policy.domain_network_policy.metadata[0].name
}

output "resource_quota_name" {
  description = "Name of the Kubernetes resource quota"
  value       = kubernetes_resource_quota.domain_resource_quota.metadata[0].name
}