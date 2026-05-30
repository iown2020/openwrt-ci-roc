#!/bin/bash
# 360V6 优化脚本 - 已修复所有路径错误
# 正常执行 → IP/雷神/EasyTier 全部生效

# ==================== 基础设置 ====================
# 修改默认 IP 为 192.168.50.1
sed -i 's/192.168.1.1/192.168.50.1/g' package/base-files/files/bin/config_generate

# 修改主机名
sed -i 's/OpenWrt/360V6/g' package/base-files/files/bin/config_generate

# ==================== 安装第三方插件 ====================
# 雷神加速器
git clone --depth 1 https://github.com/hik4869/leigod-acc.git package/leigod-acc
git clone --depth 1 https://github.com/hik4869/luci-app-leigod-acc.git package/luci-app-leigod-acc

# EasyTier
git clone --depth 1 https://github.com/EasyTier/luci-app-easytier.git package/luci-app-easytier

# ==================== 优化配置 ====================
# 无线驱动优化
mkdir -p files/etc/modprobe.d
cat > files/etc/modprobe.d/ath11k.conf << EOF
options ath11k irq_mode=0x1
options ath11k disable_160mhz=1
EOF

# 系统内核优化
mkdir -p files/etc/sysctl.d
cat > files/etc/sysctl.d/99-performance.conf << EOF
vm.swappiness=10
vm.vfs_cache_pressure=50
net.core.netdev_max_backlog=5000
net.core.somaxconn=4096
net.ipv4.tcp_fin_timeout=30
net.ipv4.tcp_congestion_control=cubic
EOF

# 国内 NTP 时间服务器
cat > files/etc/config/system << EOF
config system
        option hostname '360V6'
        option timezone 'CST-8'
        option ttylogin '0'
        option log_size '64'
        option urandom_seed '0'

config timeserver 'ntp'
        list server 'ntp.aliyun.com'
        list server 'time1.aliyun.com'
        list server 'cn.pool.ntp.org'
EOF

# 开启插件
echo "CONFIG_PACKAGE_luci-app-leigod-acc=y" >> .config
echo "CONFIG_PACKAGE_luci-app-easytier=y" >> .config

# 完成
make defconfig
