#!/bin/bash
# 360V6专属DIY脚本 - 仅保留网络向导+EasyTier+基础优化

# ==================== 基础配置修改 ====================
# 修改默认IP为192.168.2.1
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# 修改主机名为360V6
sed -i "s/hostname='.*'/hostname='360V6'/g" package/base-files/files/bin/config_generate

# 修改固件版本显示（添加编译时间）
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

# ==================== 移除不需要的包 ====================
# 移除冲突/无用的旧版本包
rm -rf feeds/luci/applications/luci-app-netwizard
rm -rf feeds/packages/net/easytier

# ==================== 添加第三方源 ====================
# 添加EasyTier官方源（最新稳定版）
echo "src-git easytier https://github.com/EasyTier/luci-app-easytier.git" >> feeds.conf.default

# 更新并安装所有feeds
./scripts/feeds update -a
./scripts/feeds install -a

# ==================== 强制启用NSS硬件加速 ====================
# 确保NSS相关包被选中
echo "CONFIG_PACKAGE_kmod-qca-nss-dp=y" >> .config
echo "CONFIG_PACKAGE_kmod-qca-nss-ecm=y" >> .config
echo "CONFIG_NSS_FIRMWARE_VERSION_11_4=y" >> .config

# 重新生成配置
make defconfig
