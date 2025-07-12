# OpenStack Storage Module
# 프라이빗 클라우드를 위한 블록 스토리지 및 객체 스토리지

terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
  }
}

# Volume Types 정의
resource "openstack_blockstorage_volume_type_v3" "ssd" {
  name        = "${var.stage}-${var.servicename}-ssd"
  description = "High performance SSD storage"
  
  extra_specs = {
    "volume_backend_name" = "ssd_backend"
    "replication_enabled" = "true"
  }
}

resource "openstack_blockstorage_volume_type_v3" "hdd" {
  name        = "${var.stage}-${var.servicename}-hdd"
  description = "Standard HDD storage"
  
  extra_specs = {
    "volume_backend_name" = "hdd_backend"
    "replication_enabled" = "false"
  }
}

# Master Node Storage Volumes
resource "openstack_blockstorage_volume_v3" "master_etcd" {
  count       = var.master_count
  name        = "${var.stage}-master-etcd-${count.index + 1}"
  description = "etcd storage for master node ${count.index + 1}"
  size        = var.etcd_volume_size
  volume_type = openstack_blockstorage_volume_type_v3.ssd.name
  
  metadata = {
    component   = "etcd"
    role        = "master"
    node_index  = tostring(count.index + 1)
    environment = var.stage
  }
}

# Worker Node Storage Volumes (for container storage)
resource "openstack_blockstorage_volume_v3" "worker_storage" {
  count       = var.worker_count
  name        = "${var.stage}-worker-storage-${count.index + 1}"
  description = "Container storage for worker node ${count.index + 1}"
  size        = var.worker_volume_size
  volume_type = openstack_blockstorage_volume_type_v3.ssd.name
  
  metadata = {
    component   = "container-storage"
    role        = "worker"
    node_index  = tostring(count.index + 1)
    environment = var.stage
  }
}

# Database Storage Volumes
resource "openstack_blockstorage_volume_v3" "database_data" {
  count       = var.database_count
  name        = "${var.stage}-database-data-${count.index + 1}"
  description = "Database data storage for instance ${count.index + 1}"
  size        = var.database_volume_size
  volume_type = openstack_blockstorage_volume_type_v3.ssd.name
  
  metadata = {
    component   = "database-data"
    role        = "database"
    node_index  = tostring(count.index + 1)
    environment = var.stage
  }
}

resource "openstack_blockstorage_volume_v3" "database_backup" {
  count       = var.database_count
  name        = "${var.stage}-database-backup-${count.index + 1}"
  description = "Database backup storage for instance ${count.index + 1}"
  size        = var.database_backup_volume_size
  volume_type = openstack_blockstorage_volume_type_v3.hdd.name
  
  metadata = {
    component   = "database-backup"
    role        = "database"
    node_index  = tostring(count.index + 1)
    environment = var.stage
  }
}

# Ceph Object Storage Volumes (for MinIO-like functionality)
resource "openstack_blockstorage_volume_v3" "object_storage" {
  count       = var.object_storage_node_count
  name        = "${var.stage}-object-storage-${count.index + 1}"
  description = "Object storage volume for node ${count.index + 1}"
  size        = var.object_storage_volume_size
  volume_type = openstack_blockstorage_volume_type_v3.hdd.name
  
  metadata = {
    component   = "object-storage"
    role        = "storage"
    node_index  = tostring(count.index + 1)
    environment = var.stage
  }
}

# Shared Storage for Persistent Volumes
resource "openstack_blockstorage_volume_v3" "shared_storage" {
  count       = var.shared_storage_count
  name        = "${var.stage}-shared-storage-${count.index + 1}"
  description = "Shared storage for Kubernetes PVs ${count.index + 1}"
  size        = var.shared_storage_volume_size
  volume_type = openstack_blockstorage_volume_type_v3.ssd.name
  multiattach = true
  
  metadata = {
    component   = "shared-storage"
    role        = "persistent-volume"
    node_index  = tostring(count.index + 1)
    environment = var.stage
  }
}

# Swift Object Storage Container (if Swift is available)
resource "openstack_objectstorage_container_v1" "microservices_storage" {
  count = var.enable_swift_storage ? length(var.storage_containers) : 0
  name  = "${var.stage}-${var.servicename}-${var.storage_containers[count.index]}"
  
  metadata = {
    environment = var.stage
    service     = var.servicename
    container   = var.storage_containers[count.index]
  }
  
  versioning {
    type  = "versions"
    count = var.swift_versioning_count
  }
}

# Volume Attachments (these will be handled by compute module)
# But we provide the volume IDs as outputs for reference

# Backup Snapshots for Critical Volumes
resource "openstack_blockstorage_volume_v3" "master_etcd_backup" {
  count       = var.enable_backups ? var.master_count : 0
  name        = "${var.stage}-master-etcd-backup-${count.index + 1}"
  description = "Backup volume for master etcd ${count.index + 1}"
  size        = var.etcd_volume_size
  volume_type = openstack_blockstorage_volume_type_v3.hdd.name
  source_vol_id = openstack_blockstorage_volume_v3.master_etcd[count.index].id
  
  metadata = {
    component   = "etcd-backup"
    role        = "backup"
    source_volume = openstack_blockstorage_volume_v3.master_etcd[count.index].id
    environment = var.stage
  }
}