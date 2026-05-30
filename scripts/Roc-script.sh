#!/bin/bash
# 360V6 全自动优化脚本 - 无报错版
# 执行后：IP=192.168.50.1 + 雷神 + EasyTier + 全部优化生效

# ==================== 1. 修改默认 IP 192.168.50.1 ====================
sed -i 's/192.168.1.1/192.168.50.1/g' package/base-files/files/bin/config_generate

# ==================== 2. 第三方插件源码拉取 ====================
# 雷神加速器
git clone --depth 1 https://github.com/hik4869/leigod-acc.git package/leigod-acc
git clone --depth 1 https://github.com/hik4869/luci-app-leigod-acc.git package/luci-app-leigod-acc

# EasyTier
git clone --depth 1 https://github.com/EasyTier/luci-app-easytier.git package/luci-app-easytier

# ==================== 3. 无线驱动优化 ====================
mkdir -p files/etc/modprobe.d
cat > files/etc/modprobe.d/ath11k.conf << EOF
options ath11k irq_mode=0x1
options ath11k disable_160mhz=1
EOF

# ==================== 4. 系统内核&网络优化 ====================
mkdir -p files/etc/sysctl.d
cat > files/etc/sysctl.d/99-performance.conf << EOF
vm.swappiness=10
vm.vfs_cache_pressure=50
net.core.netdev_max_backlog=5000
net.core.somaxconn=4096
net.ipv4.tcp_fin_timeout=30
net.ipv4.tcp_congestion_control=cubic
EOF

# ==================== 5. 国内NTP + 日志优化 ====================
mkdir -p files/etc/config
cat > files/etc/config/system << EOF
config system
        option hostname '360V6'
        option timezone 'CST-8'
        option log_size '64'

config timeserver 'ntp'
        list server 'ntp.aliyun.com'
        list server 'time1.aliyun.com'
        list server 'cn.pool.ntp.org'
EOF

# ==================== 6. 强制开启插件 ====================
echo "CONFIG_PACKAGE_luci-app-leigod-acc=y" >> .config
echo "CONFIG_PACKAGE_luci-app-easytier=y" >> .config

make defconfig
