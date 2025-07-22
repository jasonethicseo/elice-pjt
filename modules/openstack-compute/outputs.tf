output "master_instances" {
  description = "List of master instance objects"
  value       = openstack_compute_instance_v2.k8s_master
}

output "worker_instances" {
  description = "List of worker instance objects"
  value       = openstack_compute_instance_v2.k8s_worker
}

output "database_instances" {
  description = "List of database instance objects"
  value       = openstack_compute_instance_v2.database
}

output "loadbalancer_instance" {
  description = "Load balancer instance object"
  value       = var.enable_loadbalancer ? openstack_compute_instance_v2.loadbalancer[0] : null
}

output "master_ips" {
  description = "List of master node IP addresses"
  value       = openstack_compute_instance_v2.k8s_master[*].access_ip_v4
}

output "worker_ips" {
  description = "List of worker node IP addresses"
  value       = openstack_compute_instance_v2.k8s_worker[*].access_ip_v4
}

output "database_ips" {
  description = "List of database instance IP addresses"
  value       = openstack_compute_instance_v2.database[*].access_ip_v4
}

output "loadbalancer_ip" {
  description = "Load balancer IP address"
  value       = var.enable_loadbalancer ? openstack_compute_instance_v2.loadbalancer[0].access_ip_v4 : null
}

output "loadbalancer_floating_ip" {
  description = "Load balancer floating IP address"
  value       = var.enable_loadbalancer && var.enable_external_access ? openstack_networking_floatingip_v2.loadbalancer_fip[0].address : null
}

output "keypair_name" {
  description = "Name of the created key pair"
  value       = openstack_compute_keypair_v2.k8s_keypair.name
}