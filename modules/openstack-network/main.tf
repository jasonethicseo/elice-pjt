# OpenStack Network Module
# 프라이빗 클라우드를 위한 네트워크 구성

terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
  }
}

# Private Network 생성
resource "openstack_networking_network_v2" "private_network" {
  name           = "${var.stage}-${var.servicename}-network"
  admin_state_up = "true"
  
  tags = merge(var.tags, {
    Component = "Network"
    Type      = "Private"
  })
}

# Subnet 생성
resource "openstack_networking_subnet_v2" "private_subnet" {
  name       = "${var.stage}-${var.servicename}-subnet"
  network_id = openstack_networking_network_v2.private_network.id
  cidr       = var.vpc_ip_range
  ip_version = 4
  
  dns_nameservers = var.dns_nameservers
  
  allocation_pool {
    start = var.allocation_pool_start
    end   = var.allocation_pool_end
  }
  
  tags = merge(var.tags, {
    Component = "Subnet"
  })
}

# Router 생성
resource "openstack_networking_router_v2" "router" {
  name                = "${var.stage}-${var.servicename}-router"
  admin_state_up      = true
  external_network_id = var.external_network_id
  
  tags = merge(var.tags, {
    Component = "Router"
  })
}

# Router Interface 연결
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.private_subnet.id
}

# Security Group 생성
resource "openstack_networking_secgroup_v2" "k8s_security_group" {
  name        = "${var.stage}-${var.servicename}-k8s-sg"
  description = "Security group for Kubernetes cluster"
  
  tags = merge(var.tags, {
    Component = "SecurityGroup"
    Purpose   = "Kubernetes"
  })
}

# Security Group Rules
resource "openstack_networking_secgroup_rule_v2" "k8s_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.k8s_security_group.id
}

resource "openstack_networking_secgroup_rule_v2" "k8s_api" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = var.vpc_ip_range
  security_group_id = openstack_networking_secgroup_v2.k8s_security_group.id
}

resource "openstack_networking_secgroup_rule_v2" "k8s_etcd" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2379
  port_range_max    = 2380
  remote_ip_prefix  = var.vpc_ip_range
  security_group_id = openstack_networking_secgroup_v2.k8s_security_group.id
}

resource "openstack_networking_secgroup_rule_v2" "k8s_kubelet" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10250
  remote_ip_prefix  = var.vpc_ip_range
  security_group_id = openstack_networking_secgroup_v2.k8s_security_group.id
}

resource "openstack_networking_secgroup_rule_v2" "k8s_nodeport" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 30000
  port_range_max    = 32767
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.k8s_security_group.id
}

# Allow all outbound traffic
resource "openstack_networking_secgroup_rule_v2" "k8s_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.k8s_security_group.id
}

# Database Security Group
resource "openstack_networking_secgroup_v2" "db_security_group" {
  name        = "${var.stage}-${var.servicename}-db-sg"
  description = "Security group for database servers"
  
  tags = merge(var.tags, {
    Component = "SecurityGroup"
    Purpose   = "Database"
  })
}

resource "openstack_networking_secgroup_rule_v2" "db_postgresql" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5432
  port_range_max    = 5432
  remote_ip_prefix  = var.vpc_ip_range
  security_group_id = openstack_networking_secgroup_v2.db_security_group.id
}