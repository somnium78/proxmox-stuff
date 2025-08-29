#!/bin/bash
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
