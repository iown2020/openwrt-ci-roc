#!/bin/bash
# ==============================================
# 360V6专属DIY脚本（最终版）
# 包含OpenClash+AdGuardHome+EasyTier+网络向导
# 默认LAN地址：192.168.50.1
# ==============================================

# ==================== 基础系统配置 ====================
# 修改默认IP为192.168.50.1
sed -i 's/192.168.1.1/192.168.50.1/g' package/base-files/files/bin/config_generate

# 修改主机名为360V6
sed -i "s/hostname='.*'/hostname='360V6'/g" package/base-files/files/bin/config_generate

# 修改固件版本显示
sed -i "s#_('Firmware Version'), (L\.isObject(boardinfo\.release) ? boardinfo\.release\.description + ' / ' : '') + (luciversion || ''),# \
            _('Firmware Version'),\n \
            E('span', {}, [\n \
                (L.isObject(boardinfo.release)\n \
                ? boardinfo.release.description + ' / '\n \
                : '') + (luciversion || '') + ' / ',\n \
            E('a', {\n \
                href: 'https://github.com/laipeng668/openwrt-6.x',\n \
                target: '_blank',\n \
                rel: 'noopener noreferrer'\n \
                }, [ 'Built for 360V6 $(date "+%Y-%m-%d")' ])\n \
            ]),#" feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js

# ==================== 添加第三方源 ====================
# 添加EasyTier官方源（最新稳定版）
echo "src-git easytier https://github.com/EasyTier/luci-app-easytier.git" >> feeds.conf.default

# ==================== 更新并安装所有Feeds ====================
./scripts/feeds update -a
./scripts/feeds install -a

# 强制安装所有第三方插件
./scripts/feeds install -a -p easytier
./scripts/feeds install luci-app-netwizard
./scripts/feeds install luci-app-easytier
./scripts/feeds install adguardhome
./scripts/feeds install luci-app-adguardhome
./scripts/feeds install luci-app-openclash

# ==================== 强制确保核心功能启用 ====================
# NSS硬件加速
echo "CONFIG_PACKAGE_kmod-qca-nss-dp=y" >> .config
echo "CONFIG_PACKAGE_kmod-qca-nss-ecm=y" >> .config
echo "CONFIG_NSS_FIRMWARE_VERSION_11_4=y" >> .config

# 网络向导
echo "CONFIG_PACKAGE_luci-app-netwizard=y" >> .config
echo "CONFIG_PACKAGE_luci-i18n-netwizard-zh-cn=y" >> .config

# AdGuardHome广告拦截
echo "CONFIG_PACKAGE_adguardhome=y" >> .config
echo "CONFIG_PACKAGE_luci-app-adguardhome=y" >> .config
echo "CONFIG_PACKAGE_luci-i18n-adguardhome-zh-cn=y" >> .config

# EasyTier虚拟组网
echo "CONFIG_PACKAGE_easytier=y" >> .config
echo "CONFIG_PACKAGE_luci-app-easytier=y" >> .config
echo "CONFIG_PACKAGE_luci-i18n-easytier-zh-cn=y" >> .config

# OpenClash科学上网
echo "CONFIG_PACKAGE_luci-app-openclash=y" >> .config
echo "CONFIG_PACKAGE_luci-i18n-openclash-zh-cn=y" >> .config

# 重新生成最终配置
make defconfig
