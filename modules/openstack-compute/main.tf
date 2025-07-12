# OpenStack Compute Module
# 프라이빗 클라우드를 위한 컴퓨트 인스턴스 관리

terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
  }
}

# Key Pair 생성 (SSH 접근용)
resource "openstack_compute_keypair_v2" "k8s_keypair" {
  name       = "${var.stage}-${var.servicename}-keypair"
  public_key = var.public_key
}

# Master Nodes (Control Plane)
resource "openstack_compute_instance_v2" "k8s_master" {
  count       = var.master_count
  name        = "${var.stage}-k8s-master-${count.index + 1}"
  image_name  = var.image_name
  flavor_name = var.master_flavor
  key_pair    = openstack_compute_keypair_v2.k8s_keypair.name
  
  network {
    name = var.network_name
  }
  
  security_groups = [var.k8s_security_group_name]
  
  metadata = {
    role        = "master"
    cluster     = "${var.stage}-${var.servicename}"
    environment = var.stage
  }
  
  user_data = base64encode(templatefile("${path.module}/scripts/master-init.sh", {
    cluster_name = "${var.stage}-${var.servicename}"
    node_index   = count.index + 1
  }))
  
  tags = merge(var.tags, {
    Component = "ComputeInstance"
    Role      = "Master"
    NodeIndex = tostring(count.index + 1)
  })
}

# Worker Nodes
resource "openstack_compute_instance_v2" "k8s_worker" {
  count       = var.worker_count
  name        = "${var.stage}-k8s-worker-${count.index + 1}"
  image_name  = var.image_name
  flavor_name = var.worker_flavor
  key_pair    = openstack_compute_keypair_v2.k8s_keypair.name
  
  network {
    name = var.network_name
  }
  
  security_groups = [var.k8s_security_group_name]
  
  metadata = {
    role        = "worker"
    cluster     = "${var.stage}-${var.servicename}"
    environment = var.stage
  }
  
  user_data = base64encode(templatefile("${path.module}/scripts/worker-init.sh", {
    cluster_name = "${var.stage}-${var.servicename}"
    node_index   = count.index + 1
  }))
  
  tags = merge(var.tags, {
    Component = "ComputeInstance"
    Role      = "Worker"
    NodeIndex = tostring(count.index + 1)
  })
}

# Database Instances
resource "openstack_compute_instance_v2" "database" {
  count       = var.database_count
  name        = "${var.stage}-database-${count.index + 1}"
  image_name  = var.image_name
  flavor_name = var.database_flavor
  key_pair    = openstack_compute_keypair_v2.k8s_keypair.name
  
  network {
    name = var.network_name
  }
  
  security_groups = [var.db_security_group_name]
  
  metadata = {
    role        = "database"
    cluster     = "${var.stage}-${var.servicename}"
    environment = var.stage
  }
  
  user_data = base64encode(templatefile("${path.module}/scripts/database-init.sh", {
    cluster_name = "${var.stage}-${var.servicename}"
    node_index   = count.index + 1
  }))
  
  tags = merge(var.tags, {
    Component = "ComputeInstance"
    Role      = "Database"
    NodeIndex = tostring(count.index + 1)
  })
}

# LoadBalancer Instance (HAProxy)
resource "openstack_compute_instance_v2" "loadbalancer" {
  count       = var.enable_loadbalancer ? 1 : 0
  name        = "${var.stage}-loadbalancer"
  image_name  = var.image_name
  flavor_name = var.loadbalancer_flavor
  key_pair    = openstack_compute_keypair_v2.k8s_keypair.name
  
  network {
    name = var.network_name
  }
  
  security_groups = [var.k8s_security_group_name]
  
  metadata = {
    role        = "loadbalancer"
    cluster     = "${var.stage}-${var.servicename}"
    environment = var.stage
  }
  
  user_data = base64encode(templatefile("${path.module}/scripts/loadbalancer-init.sh", {
    cluster_name = "${var.stage}-${var.servicename}"
    master_ips   = openstack_compute_instance_v2.k8s_master[*].access_ip_v4
  }))
  
  tags = merge(var.tags, {
    Component = "ComputeInstance"
    Role      = "LoadBalancer"
  })
}

# Floating IP for LoadBalancer (External Access)
resource "openstack_networking_floatingip_v2" "loadbalancer_fip" {
  count = var.enable_loadbalancer && var.enable_external_access ? 1 : 0
  pool  = var.external_network_name
  
  tags = merge(var.tags, {
    Component = "FloatingIP"
    Purpose   = "LoadBalancer"
  })
}

resource "openstack_compute_floatingip_associate_v2" "loadbalancer_fip_associate" {
  count       = var.enable_loadbalancer && var.enable_external_access ? 1 : 0
  floating_ip = openstack_networking_floatingip_v2.loadbalancer_fip[0].address
  instance_id = openstack_compute_instance_v2.loadbalancer[0].id
}