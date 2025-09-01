#!/bin/bash
#
# Proxmox Kernel & System Optimization Script
# 
# Purpose: Applies comprehensive system-level optimizations including kernel
#          parameters, sysctl settings, ZFS tuning, VM/LXC disk optimizations,
#          and datacenter configuration. Configures AMD-specific kernel options
#          and system parameters for optimal Proxmox performance.
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
#   - Checks and enables non-free firmware repositories
#   - Installs AMD/Intel microcode packages
#   - Sets migration: insecure in datacenter.cfg
#   - Checks VM disk settings for discard and SSD flags
#   - Checks LXC root filesystem for lazytime and discard
#   - Applies network optimizations
#   - Applies sysctl settings immediately
#   - Refreshes boot configuration with proxmox-boot-tool
#
# ⚠️  WARNING: This script modifies critical system settings!
#     - Disables CPU mitigations (security vs performance trade-off)
#     - Sets insecure migration (security vs performance trade-off)
#     - Requires system reboot for kernel parameters to take effect
#     - Only use in trusted, isolated environments
#
# Expected results:
#   - 10-15% performance improvement
#   - Better memory management
#   - Optimized I/O performance
#   - Faster VM migrations
#   - Reduced boot time
#   - Updated microcode for security and stability
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

echo "=== Proxmox Kernel & System Optimization ==="

# 0. Non-free firmware Repository und Microcode prüfen/installieren
echo "Step 0: Checking and configuring non-free firmware..."

# Prüfen ob non-free-firmware bereits in sources.list vorhanden ist
if ! grep -q "non-free-firmware" /etc/apt/sources.list; then
    echo "Adding non-free-firmware to repositories..."
    # Backup der sources.list
    cp /etc/apt/sources.list /etc/apt/sources.list.backup

    # non-free-firmware zu allen Debian-Repositories hinzufügen
    sed -i 's/main$/main non-free-firmware/g' /etc/apt/sources.list

    echo "Updated repositories. Running apt update..."
    apt update
else
    echo "Non-free firmware repositories already configured."
fi

# CPU-Typ erkennen und entsprechende Microcode installieren
CPU_VENDOR=$(lscpu | grep "Vendor ID" | awk '{print $3}')
echo "Detected CPU vendor: $CPU_VENDOR"

case $CPU_VENDOR in
    "AuthenticAMD")
        if ! dpkg -l | grep -q "amd64-microcode"; then
            echo "Installing AMD microcode..."
            apt install -y amd64-microcode
        else
            echo "AMD microcode already installed."
        fi
        ;;
    "GenuineIntel")
        if ! dpkg -l | grep -q "intel-microcode"; then
            echo "Installing Intel microcode..."
            apt install -y intel-microcode
        else
            echo "Intel microcode already installed."
        fi
        ;;
    *)
        echo "Unknown CPU vendor: $CPU_VENDOR - skipping microcode installation"
        ;;
esac

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

# 5. Network optimieren
echo "Step 5: Optimizing network settings..."
cat > /etc/sysctl.d/network.conf << 'EOF'
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
EOF

# 6. ZFS ARC optimieren (dynamisch basierend auf RAM)
echo "Step 6: Optimizing ZFS ARC settings..."
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

# 7. Datacenter.cfg Migration Setting
echo "Step 7: Configuring datacenter migration settings..."
DATACENTER_CFG="/etc/pve/datacenter.cfg"
if [ -f "$DATACENTER_CFG" ]; then
    if ! grep -q "migration: insecure" "$DATACENTER_CFG"; then
        echo "Adding migration: insecure to datacenter.cfg..."
        echo "migration: insecure" >> "$DATACENTER_CFG"
    else
        echo "Migration: insecure already configured."
    fi
else
    echo "Creating datacenter.cfg with migration: insecure..."
    echo "migration: insecure" > "$DATACENTER_CFG"
fi

# 8. VM Disk Settings prüfen
echo "Step 8: Checking VM disk settings..."
VM_ISSUES=0
for vmid in $(qm list | awk 'NR>1 {print $1}'); do
    if [ -f "/etc/pve/qemu-server/${vmid}.conf" ]; then
        echo "Checking VM $vmid..."

        # Alle Disk-Einträge durchgehen
        while IFS= read -r line; do
            if [[ $line =~ ^(scsi|virtio|ide|sata)[0-9]+: ]]; then
                disk_line="$line"
                disk_name=$(echo "$line" | cut -d':' -f1)

                # Prüfen auf discard und ssd
                if [[ ! $disk_line =~ discard=on ]]; then
                    echo "  ⚠️  VM $vmid: $disk_name missing discard=on"
                    VM_ISSUES=$((VM_ISSUES + 1))
                fi

                if [[ ! $disk_line =~ ssd=1 ]]; then
                    echo "  ⚠️  VM $vmid: $disk_name missing ssd=1"
                    VM_ISSUES=$((VM_ISSUES + 1))
                fi
            fi
        done < "/etc/pve/qemu-server/${vmid}.conf"
    fi
done

if [ $VM_ISSUES -eq 0 ]; then
    echo "  ✅ All VM disks properly configured"
else
    echo "  ❌ Found $VM_ISSUES VM disk configuration issues"
fi

# 9. LXC Root Filesystem Settings prüfen
echo "Step 9: Checking LXC root filesystem settings..."
LXC_ISSUES=0
for ctid in $(pct list | awk 'NR>1 {print $1}'); do
    if [ -f "/etc/pve/lxc/${ctid}.conf" ]; then
        echo "Checking LXC $ctid..."

        # Rootfs-Eintrag prüfen
        if grep -q "^rootfs:" "/etc/pve/lxc/${ctid}.conf"; then
            rootfs_line=$(grep "^rootfs:" "/etc/pve/lxc/${ctid}.conf")

            # Prüfen auf lazytime
            if [[ ! $rootfs_line =~ lazytime=1 ]]; then
                echo "  ⚠️  LXC $ctid: rootfs missing lazytime=1"
                LXC_ISSUES=$((LXC_ISSUES + 1))
            fi

            # Prüfen auf discard (nur bei ZFS/SSD Storage)
            if [[ $rootfs_line =~ local-zfs ]] && [[ ! $rootfs_line =~ discard=1 ]]; then
                echo "  ⚠️  LXC $ctid: rootfs missing discard=1"
                LXC_ISSUES=$((LXC_ISSUES + 1))
            fi
        fi
    fi
done

if [ $LXC_ISSUES -eq 0 ]; then
    echo "  ✅ All LXC root filesystems properly configured"
else
    echo "  ❌ Found $LXC_ISSUES LXC filesystem configuration issues"
fi

# 10. Sysctl Settings sofort anwenden
echo "Step 10: Applying sysctl settings..."
sysctl -p /etc/sysctl.d/ipv6.conf
sysctl -p /etc/sysctl.d/swappiness.conf
sysctl -p /etc/sysctl.d/writeback.conf
sysctl -p /etc/sysctl.d/network.conf

# 11. Status anzeigen
echo
echo "=== Configuration Applied ==="
echo "Non-free firmware status:"
if grep -q "non-free-firmware" /etc/apt/sources.list; then
    echo "  ✅ Non-free firmware repositories: ENABLED"
else
    echo "  ❌ Non-free firmware repositories: DISABLED"
fi

echo "  Microcode packages:"
if dpkg -l | grep -q "amd64-microcode"; then
    echo "    ✅ AMD microcode: INSTALLED"
fi
if dpkg -l | grep -q "intel-microcode"; then
    echo "    ✅ Intel microcode: INSTALLED"
fi

echo
echo "Datacenter configuration:"
if grep -q "migration: insecure" /etc/pve/datacenter.cfg 2>/dev/null; then
    echo "  ✅ Migration: insecure ENABLED"
else
    echo "  ❌ Migration: insecure NOT SET"
fi

echo
echo "VM/LXC disk optimization status:"
echo "  VM disk issues found: $VM_ISSUES"
echo "  LXC filesystem issues found: $LXC_ISSUES"

echo
echo "Kernel cmdline:"
cat /etc/kernel/cmdline
echo
echo "Current sysctl values:"
echo "  IPv6 disabled: $(sysctl net.ipv6.conf.all.disable_ipv6 | cut -d= -f2)"
echo "  Kernel panic: $(sysctl kernel.panic | cut -d= -f2)"
echo "  Swappiness: $(sysctl vm.swappiness | cut -d= -f2)"
echo "  Writeback: $(sysctl vm.dirty_writeback_centisecs | cut -d= -f2)"
echo "  TCP congestion: $(sysctl net.ipv4.tcp_congestion_control | cut -d= -f2)"
echo "  Network qdisc: $(sysctl net.core.default_qdisc | cut -d= -f2)"
echo
echo "ZFS ARC settings:"
echo "  Max: $((ZFS_ARC_MAX / 1024 / 1024 / 1024)) GB"
echo "  Min: $((ZFS_ARC_MIN / 1024 / 1024 / 1024)) GB"
echo
echo "✅ Optimization complete!"
echo "⚠️  Reboot required for kernel parameters, ZFS settings, and microcode updates"
echo "⚠️  Manual VM/LXC disk configuration may be needed for optimal performance"
