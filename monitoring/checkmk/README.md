# Proxmox Monitoring Suite for Check_MK

A comprehensive collection of Check_MK local checks for monitoring Proxmox VE environments, including ZFS storage, LINSTOR clusters, and Proxmox-specific services.

## 📊 Overview

This monitoring suite provides **20 specialized checks** across three main categories:

### 🗄️ ZFS Monitoring (3 checks)
- **zfs_capacity**: Monitor ZFS filesystem capacity and usage with detailed metrics
- **zfs_pools**: Monitor ZFS pool health, status, and performance
- **zfs_scrub**: Monitor ZFS scrub operations and schedule compliance

### 🔗 LINSTOR Monitoring (10 checks)
- **linstor_controller**: Monitor LINSTOR controller status and connectivity
- **linstor_network**: Monitor LINSTOR network connectivity between nodes
- **linstor_nodes**: Monitor LINSTOR node status and availability
- **linstor_performance**: Monitor LINSTOR I/O performance metrics
- **linstor_resource_groups**: Monitor LINSTOR resource group configurations
- **linstor_resource**: Monitor LINSTOR resource status and placement
- **linstor_snapshots**: Monitor LINSTOR snapshot operations
- **linstor_snapshots_configurable**: Configurable LINSTOR snapshot monitoring
- **linstor_storage_pools**: Monitor LINSTOR storage pool capacity and health
- **linstor_volumes**: Monitor LINSTOR volume status and usage

### 🖥️ Proxmox Cluster Monitoring (10 checks)
- **corosync_status**: Monitor Corosync cluster communication
- **proxmox_cluster**: Monitor Proxmox cluster status and node availability
- **proxmox_vm_status**: Monitor VM status and resource allocation
- **proxmox_ct_status**: Monitor LXC container status
- **proxmox_hardware_status**: Monitor hardware status
- **proxmox_network_status**: Monitor network status
- **proxmox_security_updates**: Monitor security updates
- **proxmox_node_resources**: Monitor node CPU and memory usage
- **proxmox_storage**: Monitor Proxmox storage backends
- **proxmox_storage_capacity**: Monitor storage capacity across all backends
- **proxmox_drbd_storage**: Monitor DRBD storage replication
- **proxmox_nfs_storage**: Monitor NFS storage mounts
- **proxmox_pbs_storage**: Monitor Proxmox Backup Server integration

### 💾 Proxmox Backup Server Monitoring (1 check)

- **proxmox_backup_status**: Monitor PBS backup job status and success rates (PBS server only)


## 🚀 Quick Installation

### Install All Checks at Once

```bash
# Create local checks directory
mkdir -p /usr/lib/check_mk_agent/local

# Install ZFS Monitoring
wget -O /usr/lib/check_mk_agent/local/zfs_capacity https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/zfs/zfs_capacity
wget -O /usr/lib/check_mk_agent/local/zfs_pools https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/zfs/zfs_pools
wget -O /usr/lib/check_mk_agent/local/zfs_scrub https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/zfs/zfs_scrub

# Install LINSTOR Monitoring on Controller Node
wget -O /usr/lib/check_mk_agent/local/linstor_controller https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_controller
wget -O /usr/lib/check_mk_agent/local/linstor_network https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_network
wget -O /usr/lib/check_mk_agent/local/linstor_nodes https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_nodes
wget -O /usr/lib/check_mk_agent/local/linstor_performance https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_performance
wget -O /usr/lib/check_mk_agent/local/linstor_resource_groups https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_resource_groups
wget -O /usr/lib/check_mk_agent/local/linstor_resources https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_resources
wget -O /usr/lib/check_mk_agent/local/linstor_snapshots https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_snapshots
wget -O /usr/lib/check_mk_agent/local/linstor_snapshots_configurable https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_snapshots_configurable
wget -O /usr/lib/check_mk_agent/local/linstor_storage_pools https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_storage_pools
wget -O /usr/lib/check_mk_agent/local/linstor_volumes https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_volumes

# Install Proxmox Cluster Monitoring
wget -O /usr/lib/check_mk_agent/local/corosync_status https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/proxmox_cluster/corosync_status
wget -O /usr/lib/check_mk_agent/local/proxmox_cluster https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/proxmox_cluster/proxmox_cluster
wget -O /usr/lib/check_mk_agent/local/proxmox_vm_status https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/proxmox_cluster/proxmox_vm_status
wget -O /usr/lib/check_mk_agent/local/proxmox_ct_status https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/proxmox_cluster/proxmox_ct_status
wget -O /usr/lib/check_mk_agent/local/proxmox_hardware_status https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/proxmox_cluster/proxmox_hardware_status
wget -O /usr/lib/check_mk_agent/local/proxmox_network_status https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/proxmox_cluster/proxmox_network_status
wget -O /usr/lib/check_mk_agent/local/proxmox_security_updates https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/proxmox_cluster/proxmox_security_updates
wget -O /usr/lib/check_mk_agent/local/proxmox_node_resource https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/proxmox_cluster/proxmox_node_resource
wget -O /usr/lib/check_mk_agent/local/proxmox_storage https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/proxmox_cluster/proxmox_storage
wget -O /usr/lib/check_mk_agent/local/proxmox_storage_capacity https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/proxmox_cluster/proxmox_storage_capacity
wget -O /usr/lib/check_mk_agent/local/proxmox_drbd_storage https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/proxmox_cluster/proxmox_drbd_storage
wget -O /usr/lib/check_mk_agent/local/proxmox_nfs_storage https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/proxmox_cluster/proxmox_nfs_storage
wget -O /usr/lib/check_mk_agent/local/proxmox_pbs_storage https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/proxmox_cluster/proxmox_pbs_storage


# Install Proxmox Backup Server Monitoring (PBS server only!)
wget -O /usr/lib/check_mk_agent/local/proxmox_backup_status https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/backup/proxmox_backup_status

# Set executable permissions
chmod +x /usr/lib/check_mk_agent/local/*
```
