# LINSTOR Check_MK Monitoring

Comprehensive Check_MK local checks for monitoring LINSTOR clusters in Proxmox environments.

## 🎯 Overview

These scripts provide complete monitoring coverage for LINSTOR/DRBD clusters using Check_MK's local check mechanism. All checks use LINSTOR's JSON API (linstor -m) for reliable data parsing.

## 📊 Monitored Components

| Check | Description | Metrics |
|-------|-------------|---------|
| **linstor_resources** | DRBD resource health | Total, UpToDate, Degraded, Failed, Diskless |
| **linstor_nodes** | Cluster node status | Total, Online, Offline, Evicted |
| **linstor_resource_groups** | Resource group config | Total groups, Configuration issues |
| **linstor_storage_pools** | Storage pool health | Total, Healthy, Warnings, Errors |

## 🚀 Installation

### Prerequisites

- LINSTOR cluster running on Proxmox
- Check_MK agent installed
- linstor command available on monitored host

### Quick Install

    # Download and install all checks
    sudo mkdir -p /usr/lib/check_mk_agent/local

    # Install LINSTOR monitoring checks
    sudo wget -O /usr/lib/check_mk_agent/local/linstor_resources \
      https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_resources

    sudo wget -O /usr/lib/check_mk_agent/local/linstor_nodes \
      https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_nodes

    sudo wget -O /usr/lib/check_mk_agent/local/linstor_resource_groups \
      https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_resource_groups

    sudo wget -O /usr/lib/check_mk_agent/local/linstor_storage_pools \
      https://raw.githubusercontent.com/somnium78/proxmox-stuff/main/monitoring/checkmk/linstor/linstor_storage_pools

    # Make executable
    sudo chmod +x /usr/lib/check_mk_agent/local/linstor_*

### Manual Install

1. Copy all four scripts to /usr/lib/check_mk_agent/local/
2. Make them executable: chmod +x /usr/lib/check_mk_agent/local/linstor_*
3. Test: Run each script manually to verify output
4. Perform service discovery in Check_MK

## 🧪 Testing

    # Test all checks
    echo "=== LINSTOR Resources ==="
    /usr/lib/check_mk_agent/local/linstor_resources

    echo "=== LINSTOR Nodes ==="
    /usr/lib/check_mk_agent/local/linstor_nodes

    echo "=== LINSTOR Resource Groups ==="
    /usr/lib/check_mk_agent/local/linstor_resource_groups

    echo "=== LINSTOR Storage Pools ==="
    /usr/lib/check_mk_agent/local/linstor_storage_pools

### Expected Output (Healthy Cluster)

    0 LINSTOR_Resources total=72;uptodate=72;degraded=0;failed=0;diskless=0 OK: 72 resources (72 UpToDate, 0 degraded, 0 failed, 0 diskless)
    0 LINSTOR_Nodes total=3;online=3;offline=0;evicted=0 OK: 3 nodes (3 online, 0 offline, 0 evicted)
    0 LINSTOR_ResourceGroups total=2;config_issues=0 OK: 2 resource groups (0 with potential configuration issues)
    0 LINSTOR_StoragePools total=6;healthy=6;warnings=0;errors=0 OK: 6 storage pools (6 healthy, 0 warnings, 0 errors)

## 📈 Check_MK Integration

### Service Discovery

After installation, perform service discovery on your Check_MK server:

    # Discover services for specific host
    cmk -v --discover <hostname>

    # Or discover all marked hosts
    cmk -v --discover-marked-hosts

### Expected Services

Four new services will be created:
- **LINSTOR Resources** - Resource health monitoring
- **LINSTOR Nodes** - Cluster node availability  
- **LINSTOR ResourceGroups** - Configuration monitoring
- **LINSTOR StoragePools** - Storage pool health

## 🔔 Alert Levels

### CRITICAL (Status 2)
- **Resources**: Failed or Inconsistent resources
- **Nodes**: Evicted nodes
- **Storage Pools**: Pools with errors

### WARNING (Status 1)  
- **Resources**: Degraded resources
- **Nodes**: Offline or Unknown nodes
- **Resource Groups**: Configuration issues
- **Storage Pools**: Pools with warnings

### OK (Status 0)
- All components healthy and operational

## 🔧 Customization

### Modifying Thresholds

Edit the scripts to adjust alert thresholds:

    # Example: Only alert on failed resources, not degraded
    if [ $failed_count -gt 0 ] || [ $inconsistent_count -gt 0 ]; then
        status=2
        state="CRITICAL"
    # Remove degraded warning:
    # elif [ $degraded_count -gt 0 ]; then
    #     status=1
    #     state="WARNING"
    else
        status=0
        state="OK"
    fi

### Adding Custom Metrics

The JSON output from linstor -m contains additional fields that can be monitored:

    # Example: Monitor DRBD protocol version
    protocol_c=$(echo "$resources_json" | grep -c '"protocol": "C"')

## 🐛 Troubleshooting

### Common Issues

1. **"linstor command not found"**
   - Ensure LINSTOR client is installed
   - Check PATH includes linstor binary

2. **"Failed to query LINSTOR controller"**
   - Verify LINSTOR controller is running
   - Check network connectivity to controller
   - Validate LINSTOR client configuration

3. **"No data found" warnings**
   - Confirm LINSTOR cluster is properly configured
   - Check if resources/nodes exist: linstor node list

### Debug Mode

For debugging, run commands manually:

    # Test LINSTOR connectivity
    linstor node list

    # Test JSON output
    linstor -m node list | head -20

    # Check specific resource states
    linstor -m resource list | grep -E '"disk_state"|"name"'

## 📋 Requirements

- **LINSTOR**: Version 1.0+ (tested with 1.25+)
- **Check_MK**: Version 2.0+ (compatible with 1.6+)
- **Proxmox VE**: Version 7.0+ (tested with 8.0+)
- **OS**: Debian/Ubuntu-based systems

## 🤝 Contributing

Contributions welcome! Please:

1. Test changes in a lab environment
2. Ensure backward compatibility
3. Update documentation
4. Follow existing code style

## 📜 License

MIT License - see main repository for details.

## 🔗 Related

- [LINSTOR Documentation](https://linbit.com/drbd-user-guide/linstor-guide-1_0-en/)
- [Check_MK Local Checks](https://docs.checkmk.com/latest/en/localchecks.html)
- [Proxmox LINSTOR Integration](https://pve.proxmox.com/wiki/Storage:_LINSTOR)

---

**Author**: somnium78  
**Last Updated**: 2025-08-30  
**Version**: 1.0.0
