# LINSTOR Check_MK Monitoring

Comprehensive Check_MK local checks for monitoring LINSTOR clusters in Proxmox environments.
# 🎯 Overview

These scripts provide complete monitoring coverage for LINSTOR/DRBD clusters using Check_MK's local check mechanism. All checks use LINSTOR's JSON API (linstor -m) for reliable data parsing.
## 📊 Monitored Components
Check 	Description 	Metrics
linstor_resources 	DRBD resource health 	Total, UpToDate, Degraded, Failed, Diskless
linstor_nodes 	Cluster node status 	Total, Online, Offline, Evicted
linstor_resource_groups 	Resource group config 	Total groups, Configuration issues
linstor_storage_pools 	Storage pool health 	Total, Healthy, Warnings, Errors
linstor_snapshots 	Snapshot health and count 	Total, Successful, Failed, In-Backup
linstor_volumes 	Volume definitions and sizes 	Total, Size categories, Encryption
linstor_controller 	Controller health and version 	Responsiveness, DB health, Version match
linstor_network 	Network interfaces and connectivity 	Active interfaces, Encryption, Custom ports
linstor_performance 	Performance metrics and statistics 	Sync percentage, Read/Write operations

# 🚀 Installation
Prerequisites
    LINSTOR cluster running on Proxmox
    Check_MK agent installed
    linstor command available on monitored host

## Quick Install

# Download and install all checks
sudo mkdir -p /usr/lib/check_mk_agent/local

# Install core LINSTOR monitoring checks
sudo wget -O /usr/lib/check_mk_agent/local/linstor_resources \\
  https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_resources

sudo wget -O /usr/lib/check_mk_agent/local/linstor_nodes \\
  https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_nodes

sudo wget -O /usr/lib/check_mk_agent/local/linstor_resource_groups \\
  https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_resource_groups

sudo wget -O /usr/lib/check_mk_agent/local/linstor_storage_pools \\
  https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_storage_pools

# Install extended monitoring checks
sudo wget -O /usr/lib/check_mk_agent/local/linstor_snapshots \\
  https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_snapshots

sudo wget -O /usr/lib/check_mk_agent/local/linstor_volumes \\
  https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_volumes

sudo wget -O /usr/lib/check_mk_agent/local/linstor_controller \\
  https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_controller

sudo wget -O /usr/lib/check_mk_agent/local/linstor_network \\
  https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_network

sudo wget -O /usr/lib/check_mk_agent/local/linstor_performance \\
  https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_performance

# Make executable
sudo chmod +x /usr/lib/check_mk_agent/local/linstor_*

## Manual Install
    Copy all nine scripts to /usr/lib/check_mk_agent/local/
    Make them executable: chmod +x /usr/lib/check_mk_agent/local/linstor_*
    Test: Run each script manually to verify output
    Perform service discovery in Check_MK

Selective Installation

You can install only the checks you need:

Core Monitoring (Minimum recommended):

    linstor_resources
    linstor_nodes
    linstor_storage_pools

Extended Monitoring (Optional):

    linstor_snapshots (if using snapshots/backups)
    linstor_volumes (for capacity planning)
    linstor_controller (for controller health)
    linstor_network (for network monitoring)
    linstor_performance (for performance insights)

# 🧪 Testing

# Test core checks
echo &quot;=== LINSTOR Resources ===&quot;
/usr/lib/check_mk_agent/local/linstor_resources

echo &quot;=== LINSTOR Nodes ===&quot;
/usr/lib/check_mk_agent/local/linstor_nodes

echo &quot;=== LINSTOR Resource Groups ===&quot;
/usr/lib/check_mk_agent/local/linstor_resource_groups

echo &quot;=== LINSTOR Storage Pools ===&quot;
/usr/lib/check_mk_agent/local/linstor_storage_pools

# Test extended checks
echo &quot;=== LINSTOR Snapshots ===&quot;
/usr/lib/check_mk_agent/local/linstor_snapshots

echo &quot;=== LINSTOR Volumes ===&quot;
/usr/lib/check_mk_agent/local/linstor_volumes

echo &quot;=== LINSTOR Controller ===&quot;
/usr/lib/check_mk_agent/local/linstor_controller

echo &quot;=== LINSTOR Network ===&quot;
/usr/lib/check_mk_agent/local/linstor_network

echo &quot;=== LINSTOR Performance ===&quot;
/usr/lib/check_mk_agent/local/linstor_performance

Expected Output (Healthy Cluster)

0 LINSTOR_Resources total=72;uptodate=72;degraded=0;failed=0;diskless=0 OK: 72 resources (72 UpToDate, 0 degraded, 0 failed, 0 diskless)
0 LINSTOR_Nodes total=3;online=3;offline=0;evicted=0 OK: 3 nodes (3 online, 0 offline, 0 evicted)
0 LINSTOR_ResourceGroups total=2;config_issues=0 OK: 2 resource groups (0 with potential configuration issues)
0 LINSTOR_StoragePools total=6;healthy=6;warnings=0;errors=0 OK: 6 storage pools (6 healthy, 0 warnings, 0 errors)
0 LINSTOR_Snapshots total=0;successful=0;failed=0;in_backup=0 OK: No snapshots configured (this is normal)
0 LINSTOR_Volumes total=24;small=12;medium=8;large=4;encrypted=0;total_gb=2048 OK: 24 volumes (2048GB total, 0 encrypted)
0 LINSTOR_Controller responsive=1;db_healthy=1;version_mismatch=0 OK: Controller 1.25.1 (DB: 1, Version match: 1)
0 LINSTOR_Network total=3;active=3;inactive=0;ssl=0;custom_ports=0 OK: 3 interfaces (3 active, 0 SSL, 0 custom ports)
0 LINSTOR_Performance sync_percentage=100;in_sync=72;total=72;diskless=0 OK: 100% resources in sync (72/72)

# 📈 Check_MK Integration
## Service Discovery

After installation, perform service discovery on your Check_MK server:

# Discover services for specific host
cmk -v --discover &lt;hostname&gt;

# Or discover all marked hosts
cmk -v --discover-marked-hosts

Expected Services

Up to nine new services will be created (depending on installed checks):

Core Services:

    LINSTOR Resources - Resource health monitoring
    LINSTOR Nodes - Cluster node availability
    LINSTOR ResourceGroups - Configuration monitoring
    LINSTOR StoragePools - Storage pool health

Extended Services:

    LINSTOR Snapshots - Snapshot monitoring
    LINSTOR Volumes - Volume definition tracking
    LINSTOR Controller - Controller health monitoring
    LINSTOR Network - Network interface monitoring
    LINSTOR Performance - Performance metrics

## 🔔 Alert Levels
CRITICAL (Status 2)

    Resources: Failed or Inconsistent resources
    Nodes: Evicted nodes
    Storage Pools: Pools with errors
    Snapshots: Failed snapshots
    Controller: Controller unresponsive or database issues

WARNING (Status 1)

    Resources: Degraded resources
    Nodes: Offline or Unknown nodes
    Resource Groups: Configuration issues
    Storage Pools: Pools with warnings
    Network: Inactive interfaces
    Controller: Version mismatches

OK (Status 0)

    All components healthy and operational
    No snapshots configured (normal state)
    All resources in sync

# 🔧 Customization
# Modifying Thresholds

Edit the scripts to adjust alert thresholds:

# Example in linstor_resources: Only alert on failed resources, not degraded
if [ $failed_count -gt 0 ] || [ $inconsistent_count -gt 0 ]; then
    status=2
    state=&quot;CRITICAL&quot;
# Remove degraded warning by commenting out:
# elif [ $degraded_count -gt 0 ]; then
#     status=1
#     state=&quot;WARNING&quot;
else
    status=0
    state=&quot;OK&quot;
fi

Snapshot Monitoring Behavior

The snapshot check treats "no snapshots" as OK by default. To warn when no snapshots exist:

# Edit linstor_snapshots and change:
WARN_ON_NO_SNAPSHOTS=1

Adding Custom Metrics

The JSON output from linstor -m contains additional fields that can be monitored:

# Example: Monitor DRBD protocol version
protocol_c=$(echo &quot;$resources_json&quot; | grep -c &#x27;&quot;protocol&quot;: &quot;C&quot;&#x27;)

# Example: Monitor specific resource states
primary_resources=$(echo &quot;$resources_json&quot; | grep -c &#x27;&quot;role&quot;: &quot;Primary&quot;&#x27;)

# 🐛 Troubleshooting
## Common Issues

    "linstor command not found"
        Ensure LINSTOR client is installed
        Check PATH includes linstor binary
        Install with: apt install linstor-client

    "Failed to query LINSTOR controller"
        Verify LINSTOR controller is running: systemctl status linstor-controller
        Check network connectivity to controller
        Validate LINSTOR client configuration in /etc/linstor/linstor-client.conf

    "No data found" warnings
        Confirm LINSTOR cluster is properly configured
        Check if resources/nodes exist: linstor node list
        Verify controller database is accessible

    Permission errors
        Ensure check scripts are executable: chmod +x /usr/lib/check_mk_agent/local/linstor_*
        Check if user running checks has LINSTOR access

## Debug Mode

For debugging, run commands manually:

# Test LINSTOR connectivity
linstor node list

# Test JSON output
linstor -m node list | head -20

# Check specific resource states
linstor -m resource list | grep -E &#x27;&quot;disk_state&quot;|&quot;name&quot;&#x27;

# Verify controller connectivity
linstor controller version

# Check storage pools
linstor storage-pool list

Performance Considerations

    Checks use JSON API which is more reliable but slightly slower than text parsing
    Consider running performance-intensive checks less frequently
    Monitor Check_MK agent execution time if running all 9 checks

# 📋 Requirements

    LINSTOR: Version 1.0+ (tested with 1.25+)
    Check_MK: Version 2.0+ (compatible with 1.6+)
    Proxmox VE: Version 7.0+ (tested with 8.0+)
    OS: Debian/Ubuntu-based systems
    Dependencies: jq (optional, for advanced JSON parsing)

# 🎯 Monitoring Strategy
Minimum Setup (Production)

For basic production monitoring, install at least:

    linstor_resources (critical)
    linstor_nodes (critical)
    linstor_storage_pools (important)

Complete Setup (Enterprise)

For comprehensive monitoring, install all checks:

    Full visibility into all LINSTOR components
    Proactive issue detection
    Performance monitoring and capacity planning
    Network and security monitoring

Development/Testing

For development environments:

    linstor_resources
    linstor_nodes
    linstor_controller (for development feedback)

# 🤝 Contributing

## Contributions welcome! Please:

    Test changes in a lab environment first
    Ensure backward compatibility with existing installations
    Update documentation for any new features
    Follow existing code style and error handling patterns
    Add appropriate comments for complex logic

## Development Guidelines

    Use linstor -m for JSON output parsing
    Implement proper error handling for network issues
    Provide meaningful error messages
    Follow Check_MK local check format: STATUS SERVICE_NAME METRICS MESSAGE
    Test with different LINSTOR versions when possible

# 📜 License

MIT License - see main repository for details.

# 🔗 Related Resources
    LINSTOR Documentation
    Check_MK Local Checks Documentation
    Proxmox LINSTOR Integration Guide
    DRBD User Guide

# 📊 Monitoring Dashboard

Consider creating a Check_MK dashboard with:
    LINSTOR Cluster Overview: Node status, resource health
    Storage Capacity: Volume distribution, pool utilization
    Performance Metrics: Sync status, operation counts
    Alert Summary: Current issues and trends
    Network Health: Interface status and encryption overview

Author: somnium78
Last Updated: 2025-08-30
Version: 1.1.0
Checks Included: 9 comprehensive monitoring scripts