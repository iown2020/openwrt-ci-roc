# ==================== 新增：全套系统&网络&无线优化 ====================
# 1. ath11k 无线驱动参数
mkdir -p files/etc/modprobe.d
cat > files/etc/modprobe.d/ath11k.conf << EOF
options ath11k irq_mode=0x1
options ath11k disable_160mhz=1
EOF

# 2. 内核内存/网络栈 sysctl 调优
mkdir -p files/etc/sysctl.d
cat > files/etc/sysctl.d/99-performance.conf << EOF
vm.swappiness=10
vm.vfs_cache_pressure=50
net.core.netdev_max_backlog=5000
net.core.somaxconn=4096
net.ipv4.tcp_fin_timeout=30
net.ipv4.tcp_congestion_control=cubic
EOF

# 3. 日志优化：仅存内存、限制大小64KB
sed -i 's/log_ringbuffer_size=.*/log_ringbuffer_size=65536/' package/base-files/files/etc/systemd/system/journald.conf
sed -i 's/Storage=.*/Storage=volatile/' package/base-files/files/etc/systemd/system/journald.conf

# 4. 预设国内NTP服务器
sed -i 's/0.openwrt.pool.ntp.org/ntp.aliyun.com,time1.aliyun.com/' package/base-files/files/etc/config/system

# 5. 预设无线：区域CN、功率23dBm、漫游/波束成形
mkdir -p files/etc/config
cat > files/etc/config/wireless << EOF
config wifi-device 'radio0'
        option type 'mac80211'
        option channel 'auto'
        option band '5g'
        option htmode 'HE80'
        option country 'CN'
        option txpower '23'
        option he_su_beamformee '1'
        option he_mu_beamformee '1'
        option ieee80211r '1'
        option ieee80211k '1'
        option ieee80211v '1'

config wifi-iface 'default_radio0'
        option device 'radio0'
        option network 'lan'
        option mode 'ap'
        option ssid '360V6_5G'
        option encryption 'psk2+ccmp'
        option key '12345678'

config wifi-device 'radio1'
        option type 'mac80211'
        option channel 'auto'
        option band '2g'
        option htmode 'HT40'
        option country 'CN'
        option txpower '20'

config wifi-iface 'default_radio1'
        option device 'radio1'
        option network 'lan'
        option mode 'ap'
        option ssid '360V6_2.4G'
        option encryption 'psk2+ccmp'
        option key '12345678'
EOF

# 6. OpenClash 端口改为5353 解决DNS冲突
mkdir -p files/etc/openclash
echo 'dns_port=5353' > files/etc/openclash/config.ini

# 7. 精简多余服务
sed -i '/odhcpd/d' package/base-files/files/etc/rc.local
sed -i '/dnsmasq/d' package/base-files/files/etc/rc.local
