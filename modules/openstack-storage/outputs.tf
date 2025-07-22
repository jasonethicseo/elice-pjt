output "volume_types" {
  description = "Created volume types"
  value = {
    ssd = openstack_blockstorage_volume_type_v3.ssd
    hdd = openstack_blockstorage_volume_type_v3.hdd
  }
}

output "master_etcd_volumes" {
  description = "List of master etcd volumes"
  value       = openstack_blockstorage_volume_v3.master_etcd
}

output "worker_storage_volumes" {
  description = "List of worker storage volumes"
  value       = openstack_blockstorage_volume_v3.worker_storage
}

output "database_data_volumes" {
  description = "List of database data volumes"
  value       = openstack_blockstorage_volume_v3.database_data
}

output "database_backup_volumes" {
  description = "List of database backup volumes"
  value       = openstack_blockstorage_volume_v3.database_backup
}

output "object_storage_volumes" {
  description = "List of object storage volumes"
  value       = openstack_blockstorage_volume_v3.object_storage
}

output "shared_storage_volumes" {
  description = "List of shared storage volumes"
  value       = openstack_blockstorage_volume_v3.shared_storage
}

output "swift_containers" {
  description = "List of created Swift containers"
  value       = var.enable_swift_storage ? openstack_objectstorage_container_v1.microservices_storage : []
}

output "master_etcd_backup_volumes" {
  description = "List of master etcd backup volumes"
  value       = var.enable_backups ? openstack_blockstorage_volume_v3.master_etcd_backup : []
}

# Volume IDs for attachment
output "master_etcd_volume_ids" {
  description = "List of master etcd volume IDs"
  value       = openstack_blockstorage_volume_v3.master_etcd[*].id
}

output "worker_storage_volume_ids" {
  description = "List of worker storage volume IDs"
  value       = openstack_blockstorage_volume_v3.worker_storage[*].id
}

output "database_data_volume_ids" {
  description = "List of database data volume IDs"
  value       = openstack_blockstorage_volume_v3.database_data[*].id
}

output "database_backup_volume_ids" {
  description = "List of database backup volume IDs"
  value       = openstack_blockstorage_volume_v3.database_backup[*].id
}

output "object_storage_volume_ids" {
  description = "List of object storage volume IDs"
  value       = openstack_blockstorage_volume_v3.object_storage[*].id
}

output "shared_storage_volume_ids" {
  description = "List of shared storage volume IDs"
  value       = openstack_blockstorage_volume_v3.shared_storage[*].id
}

# Storage Summary
output "storage_summary" {
  description = "Summary of created storage resources"
  value = {
    total_volumes = (
      length(openstack_blockstorage_volume_v3.master_etcd) +
      length(openstack_blockstorage_volume_v3.worker_storage) +
      length(openstack_blockstorage_volume_v3.database_data) +
      length(openstack_blockstorage_volume_v3.database_backup) +
      length(openstack_blockstorage_volume_v3.object_storage) +
      length(openstack_blockstorage_volume_v3.shared_storage)
    )
    total_capacity_gb = (
      var.master_count * var.etcd_volume_size +
      var.worker_count * var.worker_volume_size +
      var.database_count * (var.database_volume_size + var.database_backup_volume_size) +
      var.object_storage_node_count * var.object_storage_volume_size +
      var.shared_storage_count * var.shared_storage_volume_size
    )
    swift_containers = var.enable_swift_storage ? length(var.storage_containers) : 0
  }
}