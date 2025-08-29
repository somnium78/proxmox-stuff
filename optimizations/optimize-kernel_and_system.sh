#!/bin/bash
#
# Proxmox Kernel & System Optimization Script
# 
# Purpose: Applies comprehensive system-level optimizations including kernel
#          parameters, sysctl settings, and ZFS tuning. Configures AMD-specific
#          kernel options and system parameters for optimal Proxmox performance.
#
# Prerequisites: 
#   - Proxmox VE 8.x or 9.x
#   - AMD processor (optimized for Ryzen 5000 series)
#   - Root privileges
#   - Backup of current configuration recommended
#
# Usage: 
#   ./optimize-kernel_and_system.sh
#
# Parameters:
#   None - script applies all optimizations automatically
#
# Examples:
#   ./optimize-kernel_and_system.sh
#
# What this script does:
#   - Updates /etc/kernel/cmdline with AMD optimizations
#   - Disables IPv6 and sets kernel panic behavior
#   - Optimizes swappiness (10) and writeback settings
#   - Configures ZFS ARC limits (50% max, 12.5% min of RAM)
#   - Applies sysctl settings immediately
#   - Refreshes boot configuration with proxmox-boot-tool
#
# ⚠️  WARNING: This script modifies critical system settings!
#     - Disables CPU mitigations (security vs performance trade-off)
#     - Requires system reboot for kernel parameters to take effect
#     - Only use in trusted, isolated environments
#
# Expected results:
#   - 10-15% performance improvement
#   - Better memory management
#   - Optimized I/O performance
#   - Reduced boot time
#
# Troubleshooting:
#   - Boot issues: Use Proxmox rescue mode to revert /etc/kernel/cmdline
#   - ZFS issues: Check available RAM and adjust ARC settings
#   - Performance regression: Revert sysctl files and reboot
#
# Author: somnium78
# Repository: https://github.com/somnium78/proxmox-stuff
# License: GNU General Public License v3.0
#          See https://www.gnu.org/licenses/gpl-3.0.html
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

echo "=== Proxmox Kernel & System Optimization ==="

# 1. Kernel Command Line optimieren
echo "Step 1: Optimizing kernel command line..."
cat > /etc/kernel/cmdline << 'EOF'
root=ZFS=rpool/ROOT/pve-1 boot=zfs mitigations=off nmi_watchdog=0 amd_pstate=active pcie_aspm=off nvme_core.default_ps_max_latency_us=0 kvm_amd.npt=1 kvm_amd.avic=1
EOF

echo "Kernel cmdline updated. Refreshing boot configuration..."
proxmox-boot-tool refresh

# 2. IPv6 deaktivieren und Kernel Panic Setting
echo "Step 2: Configuring IPv6 and kernel panic..."
cat > /etc/sysctl.d/ipv6.conf << 'EOF'
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
kernel.panic = 2
EOF

# 3. Swappiness optimieren
echo "Step 3: Optimizing swappiness..."
cat > /etc/sysctl.d/swappiness.conf << 'EOF'
vm.swappiness=10
EOF

# 4. Writeback optimieren
echo "Step 4: Optimizing writeback..."
cat > /etc/sysctl.d/writeback.conf << 'EOF'
vm.dirty_writeback_centisecs=1500
EOF

# 5. ZFS ARC optimieren (dynamisch basierend auf RAM)
echo "Step 5: Optimizing ZFS ARC settings..."
TOTAL_RAM=$(free -b | awk 'NR==2{print $2}')
ZFS_ARC_MAX=$((TOTAL_RAM / 2))        # 50% des RAMs
ZFS_ARC_MIN=$((TOTAL_RAM / 8))        # 12.5% des RAMs

cat > /etc/modprobe.d/zfs.conf << EOF
options zfs zfs_arc_max=$ZFS_ARC_MAX
options zfs zfs_arc_min=$ZFS_ARC_MIN
options zfs zfs_prefetch_disable=0
options zfs zfs_txg_timeout=5
options zfs zfs_vdev_scheduler=mq-deadline
EOF

# 6. Sysctl Settings sofort anwenden
echo "Step 6: Applying sysctl settings..."
sysctl -p /etc/sysctl.d/ipv6.conf
sysctl -p /etc/sysctl.d/swappiness.conf
sysctl -p /etc/sysctl.d/writeback.conf

# 7. Status anzeigen
echo
echo "=== Configuration Applied ==="
echo "Kernel cmdline:"
cat /etc/kernel/cmdline
echo
echo "Current sysctl values:"
echo "  IPv6 disabled: $(sysctl net.ipv6.conf.all.disable_ipv6 | cut -d= -f2)"
echo "  Kernel panic: $(sysctl kernel.panic | cut -d= -f2)"
echo "  Swappiness: $(sysctl vm.swappiness | cut -d= -f2)"
echo "  Writeback: $(sysctl vm.dirty_writeback_centisecs | cut -d= -f2)"
echo
echo "ZFS ARC settings:"
echo "  Max: $((ZFS_ARC_MAX / 1024 / 1024 / 1024)) GB"
echo "  Min: $((ZFS_ARC_MIN / 1024 / 1024 / 1024)) GB"
echo
echo "✅ Optimization complete!"
echo "⚠️  Reboot required for kernel parameters and ZFS settings"
