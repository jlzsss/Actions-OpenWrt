#!/bin/bash
#============================================================
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#============================================================

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# git clone https://github.com/jerrykuku/luci-app-vssr.git package/luci-app-vssr
# git clone https://github.com/jerrykuku/lua-maxminddb.git package/lua-maxminddb
# git clone https://github.com/jlzsss/luci-app-shadowsocksr.git package/luci-app-shadowsocksr
# git clone https://github.com/jlzsss/openwrt-dnsmasq-extra.git package/openwrt-dnsmasq-extra
# git clone https://github.com/tty228/luci-app-serverchan.git package/luci-app-serverchan
# git clone https://github.com/jlzsss/project-lede.git package/lede

rm -rf package/feeds/packages/php8

# git clone https://github.com/jlzsss/luci-app-passwall.git package/luci-app-passwall
# git clone https://github.com/jlzsss/openwrt-ssr-libev-full.git package/openwrt-ssr-libev-full
# git clone https://github.com/jlzsss/openwrt-ssr.git package/openwrt-ssr

# ./scripts/feeds update -a
# ./scripts/feeds install -a
