#!/bin/bash
#
# Proxmox Monitoring Checks Installation Script
# Creates all ZFS and Cluster monitoring checks
#
echo "Creating ZFS and Cluster monitoring checks..."

# 1. ZFS Pools Check
cat > zfs_pools << 'SCRIPT_EOF'
#!/bin/bash
#
# Check_MK Local Check: ZFS Pool Health
# File: /usr/lib/check_mk_agent/local/zfs_pools
#
# Monitors ZFS pool health, status and capacity
# Author: somnium78
# Version: 1.0.0
# Date: 2025-08-30
#

check_zfs_pools() {
    if ! command -v zpool >/dev/null 2>&1; then
        echo "2 ZFS_Pools - CRITICAL: zpool command not found"
        return
    fi

    # Get pool status
    pool_status=$(zpool status 2>/dev/null)

    if [ $? -ne 0 ]; then
        echo "2 ZFS_Pools - CRITICAL: Failed to query ZFS pools"
        return
    fi

    # Count pools by status
    total_pools=$(echo "$pool_status" | grep -c "pool:")

    if [ $total_pools -eq 0 ]; then
        echo "1 ZFS_Pools - WARNING: No ZFS pools found"
        return
    fi

    healthy_pools=$(echo "$pool_status" | grep -A1 "pool:" | grep -c "state: ONLINE")
    degraded_pools=$(echo "$pool_status" | grep -A1 "pool:" | grep -c "state: DEGRADED")
    faulted_pools=$(echo "$pool_status" | grep -A1 "pool:" | grep -c "state: FAULTED")
    unavail_pools=$(echo "$pool_status" | grep -A1 "pool:" | grep -c "state: UNAVAIL")

    # Check for scrub in progress
    scrub_in_progress=$(echo "$pool_status" | grep -c "scrub in progress")

    # Check for errors
    read_errors=$(echo "$pool_status" | awk '/errors:/ {sum += $2} END {print sum+0}')
    write_errors=$(echo "$pool_status" | awk '/errors:/ {sum += $3} END {print sum+0}')
    cksum_errors=$(echo "$pool_status" | awk '/errors:/ {sum += $4} END {print sum+0}')

    total_errors=$((read_errors + write_errors + cksum_errors))

    # Determine status
    if [ $faulted_pools -gt 0 ] || [ $unavail_pools -gt 0 ] || [ $total_errors -gt 0 ]; then
        status=2
        state="CRITICAL"
    elif [ $degraded_pools -gt 0 ]; then
        status=1
        state="WARNING"
    else
        status=0
        state="OK"
    fi

    echo "$status ZFS_Pools total=$total_pools;healthy=$healthy_pools;degraded=$degraded_pools;faulted=$faulted_pools;scrub_active=$scrub_in_progress;errors=$total_errors $state: $total_pools pools ($healthy_pools healthy, $degraded_pools degraded, $faulted_pools faulted, $total_errors errors)"
}

check_zfs_pools
SCRIPT_EOF

# 2. ZFS Capacity Check
cat > zfs_capacity << 'SCRIPT_EOF'
#!/bin/bash
#
# Check_MK Local Check: ZFS Capacity
# File: /usr/lib/check_mk_agent/local/zfs_capacity
#
# Monitors ZFS filesystem capacity and usage
# Author: somnium78
# Version: 1.0.0
# Date: 2025-08-30
#

check_zfs_capacity() {
    if ! command -v zfs >/dev/null 2>&1; then
        echo "2 ZFS_Capacity - CRITICAL: zfs command not found"
        return
    fi

    # Get filesystem usage
    zfs_list=$(zfs list -H -o name,used,available,mountpoint -t filesystem 2>/dev/null)

    if [ $? -ne 0 ]; then
        echo "2 ZFS_Capacity - CRITICAL: Failed to query ZFS filesystems"
        return
    fi

    total_filesystems=$(echo "$zfs_list" | wc -l)

    if [ $total_filesystems -eq 0 ]; then
        echo "1 ZFS_Capacity - WARNING: No ZFS filesystems found"
        return
    fi

    # Calculate capacity warnings (>80% = warning, >90% = critical)
    critical_fs=0
    warning_fs=0

    while IFS=$'\t' read -r name used available mountpoint; do
        if [ -n "$used" ] && [ -n "$available" ]; then
            # Convert to bytes (handle K, M, G, T suffixes)
            used_bytes=$(echo "$used" | sed 's/K/*1024/g; s/M/*1024*1024/g; s/G/*1024*1024*1024/g; s/T/*1024*1024*1024*1024/g' | bc 2>/dev/null || echo 0)
            avail_bytes=$(echo "$available" | sed 's/K/*1024/g; s/M/*1024*1024/g; s/G/*1024*1024*1024/g; s/T/*1024*1024*1024*1024/g' | bc 2>/dev/null || echo 0)

            if [ $avail_bytes -gt 0 ]; then
                total_bytes=$((used_bytes + avail_bytes))
                usage_percent=$((used_bytes * 100 / total_bytes))

                if [ $usage_percent -gt 90 ]; then
                    critical_fs=$((critical_fs + 1))
                elif [ $usage_percent -gt 80 ]; then
                    warning_fs=$((warning_fs + 1))
                fi
            fi
        fi
    done <<< "$zfs_list"

    # Determine status
    if [ $critical_fs -gt 0 ]; then
        status=2
        state="CRITICAL"
    elif [ $warning_fs -gt 0 ]; then
        status=1
        state="WARNING"
    else
        status=0
        state="OK"
    fi

    echo "$status ZFS_Capacity total=$total_filesystems;warning=$warning_fs;critical=$critical_fs $state: $total_filesystems filesystems ($warning_fs >80%, $critical_fs >90%)"
}

check_zfs_capacity
SCRIPT_EOF

# 3. ZFS Scrub Check
cat > zfs_scrub << 'SCRIPT_EOF'
#!/bin/bash
#
# Check_MK Local Check: ZFS Scrub Status
# File: /usr/lib/check_mk_agent/local/zfs_scrub
#
# Monitors ZFS scrub operations and schedules
# Author: somnium78
# Version: 1.0.0
# Date: 2025-08-30
#

check_zfs_scrub() {
    if ! command -v zpool >/dev/null 2>&1; then
        echo "2 ZFS_Scrub - CRITICAL: zpool command not found"
        return
    fi

    pool_status=$(zpool status 2>/dev/null)

    if [ $? -ne 0 ]; then
        echo "2 ZFS_Scrub - CRITICAL: Failed to query ZFS pools"
        return
    fi

    # Count scrub states
    scrub_in_progress=$(echo "$pool_status" | grep -c "scrub in progress")
    scrub_completed=$(echo "$pool_status" | grep -c "scrub repaired")
    scrub_cancelled=$(echo "$pool_status" | grep -c "scrub canceled")
    no_scrub=$(echo "$pool_status" | grep -c "none requested")

    # Check for old scrubs (>30 days)
    current_time=$(date +%s)
    old_scrubs=0

    # Extract scrub completion dates and check age
    while IFS= read -r line; do
        if echo "$line" | grep -q "scrub repaired.*on"; then
            scrub_date=$(echo "$line" | sed -n 's/.*on \([A-Za-z]* [A-Za-z]* [0-9]* [0-9]*:[0-9]*:[0-9]* [0-9]*\).*/\1/p')
            if [ -n "$scrub_date" ]; then
                scrub_timestamp=$(date -d "$scrub_date" +%s 2>/dev/null || echo 0)
                if [ $scrub_timestamp -gt 0 ]; then
                    days_ago=$(( (current_time - scrub_timestamp) / 86400 ))
                    if [ $days_ago -gt 30 ]; then
                        old_scrubs=$((old_scrubs + 1))
                    fi
                fi
            fi
        fi
    done <<< "$pool_status"

    # Determine status
    if [ $old_scrubs -gt 0 ]; then
        status=1
        state="WARNING"
    elif [ $scrub_cancelled -gt 0 ]; then
        status=1
        state="WARNING"
    else
        status=0
        state="OK"
    fi

    echo "$status ZFS_Scrub active=$scrub_in_progress;completed=$scrub_completed;cancelled=$scrub_cancelled;old_scrubs=$old_scrubs $state: Scrub status (${scrub_in_progress} active, ${old_scrubs} >30 days old)"
}

check_zfs_scrub
SCRIPT_EOF

# 4. Proxmox Cluster Check
cat > proxmox_cluster << 'SCRIPT_EOF'
#!/bin/bash
#
# Check_MK Local Check: Proxmox Cluster Status
# File: /usr/lib/check_mk_agent/local/proxmox_cluster
#
# Monitors Proxmox cluster health and node status
# Author: somnium78
# Version: 1.0.0
# Date: 2025-08-30
#

check_proxmox_cluster() {
    if ! command -v pvecm >/dev/null 2>&1; then
        echo "2 Proxmox_Cluster - CRITICAL: pvecm command not found"
        return
    fi

    # Check if this node is part of a cluster
    cluster_status=$(pvecm status 2>/dev/null)

    if [ $? -ne 0 ]; then
        echo "1 Proxmox_Cluster - WARNING: Not part of a cluster or cluster not accessible"
        return
    fi

    # Parse cluster information
    cluster_name=$(echo "$cluster_status" | grep "Cluster name:" | awk '{print $3}')
    config_version=$(echo "$cluster_status" | grep "Config Version:" | awk '{print $3}')

    # Count nodes
    total_nodes=$(echo "$cluster_status" | grep -c "^[0-9]")
    online_nodes=$(echo "$cluster_status" | grep -c "M")

    # Check quorum
    quorum_status=$(echo "$cluster_status" | grep "Quorate:" | awk '{print $2}')
    expected_votes=$(echo "$cluster_status" | grep "Expected votes:" | awk '{print $3}')
    total_votes=$(echo "$cluster_status" | grep "Total votes:" | awk '{print $3}')

    # Check if quorate
    if [ "$quorum_status" = "Yes" ]; then
        quorate=1
    else
        quorate=0
    fi

    # Determine status
    if [ $quorate -eq 0 ]; then
        status=2
        state="CRITICAL"
    elif [ $online_nodes -lt $total_nodes ]; then
        status=1
        state="WARNING"
    else
        status=0
        state="OK"
    fi

    echo "$status Proxmox_Cluster total_nodes=$total_nodes;online_nodes=$online_nodes;quorate=$quorate;expected_votes=$expected_votes;total_votes=$total_votes $state: Cluster '$cluster_name' ($online_nodes/$total_nodes nodes online, quorate: $quorum_status)"
}

check_proxmox_cluster
SCRIPT_EOF

# 5. Corosync Status Check
cat > corosync_status << 'SCRIPT_EOF'
#!/bin/bash
#
# Check_MK Local Check: Corosync Status
# File: /usr/lib/check_mk_agent/local/corosync_status
#
# Monitors Corosync cluster communication
# Author: somnium78
# Version: 1.0.0
# Date: 2025-08-30
#

check_corosync_status() {
    if ! command -v corosync-quorumtool >/dev/null 2>&1; then
        echo "2 Corosync_Status - CRITICAL: corosync-quorumtool command not found"
        return
    fi

    # Check quorum status
    quorum_info=$(corosync-quorumtool -s 2>/dev/null)

    if [ $? -ne 0 ]; then
        echo "2 Corosync_Status - CRITICAL: Failed to query corosync quorum"
        return
    fi

    # Parse quorum information
    quorate=$(echo "$quorum_info" | grep "Quorate:" | awk '{print $2}')
    nodes=$(echo "$quorum_info" | grep "Nodes:" | awk '{print $2}')
    expected_votes=$(echo "$quorum_info" | grep "Expected votes:" | awk '{print $3}')
    highest_expected=$(echo "$quorum_info" | grep "Highest expected:" | awk '{print $3}')
    total_votes=$(echo "$quorum_info" | grep "Total votes:" | awk '{print $3}')
    quorum_votes=$(echo "$quorum_info" | grep "Quorum:" | awk '{print $2}')

    # Check corosync-cfgtool for ring status
    ring_status=0
    if command -v corosync-cfgtool >/dev/null 2>&1; then
        ring_info=$(corosync-cfgtool -s 2>/dev/null)
        if [ $? -eq 0 ]; then
            # Count FAULTY rings
            faulty_rings=$(echo "$ring_info" | grep -c "FAULTY")
            if [ $faulty_rings -eq 0 ]; then
                ring_status=1
            fi
        fi
    fi

    # Convert quorate to numeric
    if [ "$quorate" = "Yes" ]; then
        quorate_num=1
    else
        quorate_num=0
    fi

    # Determine status
    if [ $quorate_num -eq 0 ]; then
        status=2
        state="CRITICAL"
    elif [ $ring_status -eq 0 ]; then
        status=1
        state="WARNING"
    else
        status=0
        state="OK"
    fi

    echo "$status Corosync_Status nodes=$nodes;quorate=$quorate_num;expected_votes=$expected_votes;total_votes=$total_votes;ring_healthy=$ring_status $state: Corosync ($nodes nodes, quorate: $quorate, votes: $total_votes/$expected_votes)"
}

check_corosync_status
SCRIPT_EOF

# Make all scripts executable
chmod +x zfs_pools zfs_capacity zfs_scrub proxmox_cluster corosync_status

echo "✅ Created 5 monitoring checks:"
echo "   - zfs_pools"
echo "   - zfs_capacity" 
echo "   - zfs_scrub"
echo "   - proxmox_cluster"
echo "   - corosync_status"
echo ""
echo "🧪 Test them with:"
echo "   ./zfs_pools"
echo "   ./zfs_capacity"
echo "   ./zfs_scrub"
echo "   ./proxmox_cluster"
echo "   ./corosync_status"
echo ""
echo "📦 Install with:"
echo "   sudo cp {zfs_pools,zfs_capacity,zfs_scrub,proxmox_cluster,corosync_status} /usr/lib/check_mk_agent/local/"
echo "   sudo chmod +x /usr/lib/check_mk_agent/local/{zfs_pools,zfs_capacity,zfs_scrub,proxmox_cluster,corosync_status}"
