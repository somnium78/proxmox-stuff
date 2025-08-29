#!/bin/bash
echo "=== AMD 5825U Optimized Configuration for pve99 ==="

# 1. AMD Microcode sicherstellen
if ! dpkg -l | grep -q amd64-microcode; then
    apt update && apt install -y amd64-microcode
fi
if dpkg -l | grep -q intel-microcode; then
    apt remove -y intel-microcode
fi

# 2. 5825U-spezifisches CPU Script (optimiert)
cat > /usr/local/bin/cpu-balanced-setup.sh << "EOF"
#!/bin/bash
# AMD 5825U Optimized Configuration

echo "Applying AMD 5825U balanced configuration..."

# 1. Powersave Governor
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo "powersave" > "$cpu"
done

# 2. Balance_Power EPP (responsive Performance bei Bedarf)
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    echo "balance_power" > "$cpu"
done

# 3. Frequency Limits
# Min: 800MHz für Responsiveness
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq; do
    echo "800000" > "$cpu"
done

# Max: 95% der maximalen Frequenz für Thermal-Management
MAX_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
SCALED_FREQ=$((MAX_FREQ * 95 / 100))
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
    echo "$SCALED_FREQ" > "$cpu"
done

echo "AMD 5825U Configuration applied:"
echo "  Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
echo "  EPP: $(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference)"
echo "  Min Freq: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq) kHz"
echo "  Max Freq: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq) kHz (95% limit for optimal balance)"
EOF

chmod +x /usr/local/bin/cpu-balanced-setup.sh

# 3. Service erstellen
cat > /etc/systemd/system/cpu-balanced.service << "EOF"
[Unit]
Description=AMD 5825U Balanced CPU Configuration
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/cpu-balanced-setup.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable cpu-balanced.service
systemctl start cpu-balanced.service

# 4. ZFS Optimierungen
cat > /etc/modprobe.d/zfs-amd.conf << "EOF"
options zfs zfs_prefetch_disable=0
options zfs zfs_txg_timeout=5
options zfs zfs_vdev_scheduler=mq-deadline
EOF

# 5. NVMe Optimierungen
cat > /etc/udev/rules.d/60-nvme-amd.rules << "EOF"
ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="mq-deadline"
ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/read_ahead_kb}="512"
EOF

# 6. Sofort anwenden
/usr/local/bin/cpu-balanced-setup.sh

echo
echo "=== AMD 5825U Configuration Complete ==="
echo "Kernel parameters already optimized ✅"
echo "Max Frequency: 95% limit for optimal performance/thermal balance"
sleep 30
echo "Temperature: $(sensors | grep Tctl | cut -d: -f2 | tr -d " " || echo "Checking...")"
echo "✅ pve99 (AMD 5825U) optimized"
