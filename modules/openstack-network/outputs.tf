output "private_network_id" {
  description = "ID of the private network"
  value       = openstack_networking_network_v2.private_network.id
}

output "private_network_name" {
  description = "Name of the private network"
  value       = openstack_networking_network_v2.private_network.name
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = openstack_networking_subnet_v2.private_subnet.id
}

output "router_id" {
  description = "ID of the router"
  value       = openstack_networking_router_v2.router.id
}

output "k8s_security_group_id" {
  description = "ID of the Kubernetes security group"
  value       = openstack_networking_secgroup_v2.k8s_security_group.id
}

output "k8s_security_group_name" {
  description = "Name of the Kubernetes security group"
  value       = openstack_networking_secgroup_v2.k8s_security_group.name
}

output "db_security_group_id" {
  description = "ID of the database security group"
  value       = openstack_networking_secgroup_v2.db_security_group.id
}

output "db_security_group_name" {
  description = "Name of the database security group"
  value       = openstack_networking_secgroup_v2.db_security_group.name
}

output "network_summary" {
  description = "Summary of network configuration"
  value = {
    vpc_cidr        = var.vpc_ip_range
    network_name    = openstack_networking_network_v2.private_network.name
    subnet_name     = openstack_networking_subnet_v2.private_subnet.name
    router_name     = openstack_networking_router_v2.router.name
    dns_servers     = var.dns_nameservers
    allocation_pool = "${var.allocation_pool_start} - ${var.allocation_pool_end}"
  }
}