output "network_info" {
  description = "Network infrastructure information"
  value = {
    private_network_id   = module.network.private_network_id
    private_network_name = module.network.private_network_name
    private_subnet_id    = module.network.private_subnet_id
    router_id           = module.network.router_id
    k8s_security_group_id = module.network.k8s_security_group_id
    db_security_group_id  = module.network.db_security_group_id
  }
}

output "compute_info" {
  description = "Compute infrastructure information"
  value = {
    master_ips              = module.compute.master_ips
    worker_ips              = module.compute.worker_ips
    database_ips            = module.compute.database_ips
    loadbalancer_ip         = module.compute.loadbalancer_ip
    loadbalancer_floating_ip = module.compute.loadbalancer_floating_ip
    keypair_name           = module.compute.keypair_name
  }
}

output "storage_info" {
  description = "Storage infrastructure information"
  value = {
    storage_summary = module.storage.storage_summary
    swift_containers = module.storage.swift_containers
    volume_types = module.storage.volume_types
  }
}

output "kubernetes_info" {
  description = "Kubernetes cluster information"
  value = {
    cluster_endpoint = module.compute.loadbalancer_floating_ip != null ? "https://${module.compute.loadbalancer_floating_ip}:6443" : null
    namespaces = {
      user    = kubernetes_namespace.microservices_user.metadata[0].name
      product = kubernetes_namespace.microservices_product.metadata[0].name
      order   = kubernetes_namespace.microservices_order.metadata[0].name
      minio   = kubernetes_namespace.microservices_minio.metadata[0].name
    }
  }
}

output "minio_info" {
  description = "MinIO object storage information"
  value = {
    api_service_name = kubernetes_service.minio_api.metadata[0].name
    console_service_name = kubernetes_service.minio_console.metadata[0].name
    namespace = kubernetes_namespace.microservices_minio.metadata[0].name
    default_credentials = {
      username = "minioadmin"
      password = "minioadmin123"
    }
  }
}

output "access_information" {
  description = "Access information for the private cloud environment"
  value = {
    ssh_access = {
      command = "ssh -i ~/.ssh/id_rsa ubuntu@${module.compute.loadbalancer_floating_ip}"
      note    = "Use the private key corresponding to the public key provided"
    }
    kubernetes_access = {
      endpoint = module.compute.loadbalancer_floating_ip != null ? "https://${module.compute.loadbalancer_floating_ip}:6443" : null
      note     = "Configure kubectl with this endpoint and proper certificates"
    }
    minio_console = {
      url      = "Access via kubectl port-forward to minio-console service"
      command  = "kubectl port-forward -n ${kubernetes_namespace.microservices_minio.metadata[0].name} svc/minio-console 9001:9001"
      username = "minioadmin"
      password = "minioadmin123"
    }
  }
}

output "next_steps" {
  description = "Next steps to complete the setup"
  value = {
    "1_kubernetes_setup" = "Install and configure Kubernetes on the created instances using Kubespray or kubeadm"
    "2_storage_setup"    = "Configure Ceph cluster on storage nodes for distributed storage"
    "3_networking"       = "Set up Calico or Cilium CNI for pod networking"
    "4_loadbalancer"     = "Configure HAProxy on the load balancer instance"
    "5_monitoring"       = "Deploy Prometheus and Grafana for monitoring"
    "6_applications"     = "Deploy microservices using Helm charts"
  }
}

# Sensitive outputs for debugging (only when needed)
output "debug_info" {
  description = "Debug information (sensitive)"
  sensitive   = true
  value = {
    openstack_region = var.openstack_region
    openstack_tenant = var.openstack_tenant_name
    network_cidr     = var.vpc_ip_range
  }
}