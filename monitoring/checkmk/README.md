# Check_MK Monitoring für Proxmox

Check_MK Local Checks für die Überwachung von Proxmox-Infrastrukturen.

## 📊 Verfügbare Monitoring-Kategorien

### 🔗 LINSTOR Monitoring
**Verzeichnis:** `linstor/`

| Check | Beschreibung |
|-------|-------------|
| `linstor_resources` | DRBD Resource Health (UpToDate, Degraded, Failed) |
| `linstor_nodes` | Cluster Node Status (Online, Offline, Evicted) |
| `linstor_storage_pools` | Storage Pool Health (Healthy, Warnings, Errors) |
| `linstor_resource_groups` | Resource Group Konfiguration |
| `linstor_snapshots` | Snapshot Health und Anzahl |
| `linstor_volumes` | Volume Definitionen und Größen |
| `linstor_controller` | Controller Health und Version |
| `linstor_network` | Netzwerk Interfaces und Konnektivität |
| `linstor_performance` | Performance Metriken und Statistiken |

### 💾 ZFS Monitoring
**Verzeichnis:** `zfs/`

| Check | Beschreibung |
|-------|-------------|
| `zfs_pools` | ZFS Pool Health (Online, Degraded, Faulted, Errors) |
| `zfs_capacity` | ZFS Filesystem Kapazität (>80% Warning, >90% Critical) |
| `zfs_scrub` | ZFS Scrub Status und Zeitplan |

### 🏘️ Proxmox Cluster Monitoring
**Verzeichnis:** `proxmox_cluster/`

| Check | Beschreibung |
|-------|-------------|
| `proxmox_cluster` | Proxmox Cluster Health (Nodes, Quorum) |
| `corosync_status` | Corosync Kommunikation (Quorum, Ring Status) |

## 🚀 Schnellinstallation

### Alle LINSTOR Checks installieren

    sudo mkdir -p /usr/lib/check_mk_agent/local
    sudo wget -O /usr/lib/check_mk_agent/local/linstor_resources https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_resources
    sudo wget -O /usr/lib/check_mk_agent/local/linstor_nodes https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_nodes
    sudo wget -O /usr/lib/check_mk_agent/local/linstor_storage_pools https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_storage_pools
    sudo wget -O /usr/lib/check_mk_agent/local/linstor_resource_groups https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_resource_groups
    sudo wget -O /usr/lib/check_mk_agent/local/linstor_snapshots https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_snapshots
    sudo wget -O /usr/lib/check_mk_agent/local/linstor_volumes https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_volumes
    sudo wget -O /usr/lib/check_mk_agent/local/linstor_controller https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_controller
    sudo wget -O /usr/lib/check_mk_agent/local/linstor_network https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_network
    sudo wget -O /usr/lib/check_mk_agent/local/linstor_performance https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_performance

### Alle ZFS Checks installieren

    sudo wget -O /usr/lib/check_mk_agent/local/zfs_pools https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/zfs/zfs_pools
    sudo wget -O /usr/lib/check_mk_agent/local/zfs_capacity https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/zfs/zfs_capacity
    sudo wget -O /usr/lib/check_mk_agent/local/zfs_scrub https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/zfs/zfs_scrub

### Alle Proxmox Cluster Checks installieren

    sudo wget -O /usr/lib/check_mk_agent/local/proxmox_cluster https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/proxmox_cluster/proxmox_cluster
    sudo wget -O /usr/lib/check_mk_agent/local/corosync_status https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/proxmox_cluster/corosync_status

### Alle Checks ausführbar machen

    sudo chmod +x /usr/lib/check_mk_agent/local/linstor_*
    sudo chmod +x /usr/lib/check_mk_agent/local/zfs_*
    sudo chmod +x /usr/lib/check_mk_agent/local/proxmox_cluster
    sudo chmod +x /usr/lib/check_mk_agent/local/corosync_status

## 🎯 Selektive Installation

### Basis-Setup (Minimum)
Für grundlegende Überwachung:

    # LINSTOR Basis
    sudo wget -O /usr/lib/check_mk_agent/local/linstor_resources https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_resources
    sudo wget -O /usr/lib/check_mk_agent/local/linstor_nodes https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_nodes
    sudo wget -O /usr/lib/check_mk_agent/local/linstor_storage_pools https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_storage_pools

    # ZFS Basis
    sudo wget -O /usr/lib/check_mk_agent/local/zfs_pools https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/zfs/zfs_pools

    # Cluster Basis
    sudo wget -O /usr/lib/check_mk_agent/local/proxmox_cluster https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/proxmox_cluster/proxmox_cluster

### Enterprise-Setup (Vollständig)
Für umfassende Überwachung alle Checks installieren (siehe Schnellinstallation oben).

## 🧪 Testen der Installation

    # Test LINSTOR Checks
    /usr/lib/check_mk_agent/local/linstor_resources
    /usr/lib/check_mk_agent/local/linstor_nodes

    # Test ZFS Checks
    /usr/lib/check_mk_agent/local/zfs_pools
    /usr/lib/check_mk_agent/local/zfs_capacity

    # Test Cluster Checks
    /usr/lib/check_mk_agent/local/proxmox_cluster
    /usr/lib/check_mk_agent/local/corosync_status

## 📈 Check_MK Service Discovery

Nach der Installation Service Discovery durchführen:

    # Auf Check_MK Server
    cmk -v --discover <hostname>

## 🔔 Alert-Level Übersicht

- **CRITICAL**: Failed Resources, Faulted Pools, Cluster ohne Quorum
- **WARNING**: Degraded Resources, Kapazität >80%, Offline Nodes
- **OK**: Alle Komponenten gesund und funktional

## 📋 Voraussetzungen

- **Proxmox VE**: Version 7.0+
- **Check_MK**: Version 2.0+ (kompatibel mit 1.6+)
- **LINSTOR**: Version 1.0+ (für LINSTOR Checks)
- **ZFS**: Für ZFS Checks
- **Cluster**: Für Cluster Checks

## 🔗 Repository-Struktur

    monitoring/checkmk/
    ├── linstor/          # LINSTOR/DRBD Monitoring (9 Checks)
    ├── zfs/              # ZFS Storage Monitoring (3 Checks)
    └── proxmox_cluster/  # Cluster Health Monitoring (2 Checks)

---

**Gesamt**: 14 Monitoring-Checks für komplette Proxmox-Infrastruktur-Überwachung.
