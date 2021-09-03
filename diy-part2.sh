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

git clone https://github.com/jerrykuku/luci-app-vssr.git package/luci-app-vssr
git clone https://github.com/jerrykuku/lua-maxminddb.git package/lua-maxminddb
# git clone https://github.com/jlzsss/luci-app-passwall.git package/luci-app-passwall
# git clone https://github.com/jlzsss/openwrt-ssr-libev-full.git package/openwrt-ssr-libev-full
# git clone https://github.com/jlzsss/openwrt-ssr.git package/openwrt-ssr

git clone https://github.com/jlzsss/luci-app-shadowsocksr.git package/luci-app-shadowsocksr
git clone https://github.com/jlzsss/openwrt-dnsmasq-extra.git package/openwrt-dnsmasq-extra
git clone https://github.com/tty228/luci-app-serverchan.git package/luci-app-serverchan
git clone https://github.com/garypang13/luci-app-bypass.git package/luci-app-bypass
git clone https://github.com/garypang13/smartdns-le.git package/smartdns-le
find package/*/ feeds/*/ -maxdepth 2 -path "*luci-app-bypass/Makefile" | xargs -i sed -i 's/shadowsocksr-libev-ssr-redir/shadowsocksr-libev-alt/g' {}
find package/*/ feeds/*/ -maxdepth 2 -path "*luci-app-bypass/Makefile" | xargs -i sed -i 's/shadowsocksr-libev-ssr-server/shadowsocksr-libev-server/g' {}
find package/*/ feeds/*/ -maxdepth 2 -path "*luci-app-ssr-libev-server/Makefile" | xargs -i sed -i 's/shadowsocksr-libev-ssr-server/shadowsocksr-libev-server/g' {}
git clone https://github.com/project-lede/luci-app-godproxy.git package/luci-app-godproxy
# git clone -b luci18 https://github.com/project-lede/openwrt-app.git package/lede
svn export --force https://github.com/project-lede/openwrt-app/branches/luci18/luci-app-autopoweroff package/luci-app-autopoweroff
svn export --force https://github.com/project-lede/openwrt-app/branches/luci18/luci-app-autoreboot package/luci-app-autoreboot
svn export --force https://github.com/project-lede/openwrt-app/branches/luci18/luci-app-autorepeater package/luci-app-autorepeater
svn export --force https://github.com/project-lede/openwrt-app/branches/luci18/luci-app-chinadns-ng package//luci-app-chinadns-ng
rm -rf package/feeds/garypang/bpytop
rm -rf package/feeds/garypang/luci-app-qosv4
rm -rf package/feeds/garypang/luci-app-speederv2
rm -rf package/feeds/garypang/luci-app-vssr
rm -rf package/feeds/garypang/sub-web
rm -rf package/feeds/garypang/luci-app-k3screenctrl
rm -rf package/feeds/garypang/luci-app-passwall

rm -rf package/lede/compressed-memory
rm -rf package/lede/luci-app-atinout
rm -rf package/lede/luci-app-pcap-dnsproxy
rm -rf package/lede/luci-app-compressed-memory
# git clone https://github.com/brvphoenix/wrtbwmon.git package/wrtbwmon
# git clone https://github.com/brvphoenix/luci-app-wrtbwmon.git package/luci-app-wrtbwmon
# svn co https://github.com/openwrt/packages/trunk/net/dawn package/feeds/packages/dawn
# svn co https://github.com/openwrt/packages/trunk/net/vnstat2 package/feeds/packages/vnstat2
# svn co https://github.com/openwrt/packages/trunk/net/openfortivpn package/feeds/packages/openfortivpn


# ./scripts/feeds update -a
# ./scripts/feeds install -a
