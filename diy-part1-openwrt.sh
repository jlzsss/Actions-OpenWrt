#!/bin/bash
#=============================================================
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#=============================================================

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#sed -i '$a src-git lienol https://github.com/Lienol/openwrt-package' feeds.conf.default

git clone https://github.com/kuoruan/luci-app-kcptun.git package/luci-app-kcptun
git clone https://github.com/jlzsss/openwrt-kcptun.git package/kcptun
git clone https://github.com/jlzsss/openwrt-miredo.git package/miredo
git clone https://github.com/Mleaf/openwrt-mwol.git package/mwol
git clone https://github.com/yichya/luci-app-xray.git package/luci-app-xray
git clone https://github.com/yichya/openwrt-xray.git package/openwrt-xray
git clone -b luci2 https://github.com/jlzsss/luci-app-v2ray.git package/luci-app-v2ray
git clone https://github.com/frainzy1477/luci-app-trojan.git package/luci-app-trojan
git clone -b test https://github.com/frainzy1477/luci-app-clash.git package/luci-app-clash
git clone https://github.com/sirpdboy/netspeedtest.git package/netspeedtest
git clone https://github.com/lisaac/luci-app-dockerman.git package/luci-app-dockerman
# git clone https://github.com/project-openwrt/luci-app-koolproxyR.git package/luci-app-koolproxyR
# git clone -b master https://github.com/vernesong/OpenClash.git package/OpenClash
# svn co https://github.com/Lienol/openwrt/trunk/package/diy package/diy
# rm -rf package/diy/luci-app-dockerman
# rm -rf package/diy/OpenAppFilter
rm -rf package/lean/luci-theme-argon
rm -rf package/lean/luci-app-dockerman
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
git clone https://github.com/NateLol/luci-app-oled.git package/luci-app-oled
git clone https://github.com/jlzsss/dnscrypt-proxy2.git package/feeds/packages/dnscrypt-proxy2
git clone https://github.com/immortalwrt-collections/openwrt-cdnspeedtest.git package/openwrt-cdnspeedtest
git clone https://github.com/jlzsss/luci-app-cloudflarespeedtest.git package/luci-app-cloudflarespeedtest
# git clone https://github.com/jlzsss/smartdns.git package/feeds/packages/smartdns
# git clone https://github.com/jlzsss/luci-app-smartdns.git package/feeds/luci/luci-app-smartdns
git clone https://github.com/jlzsss/libgd.git package/feeds/packages/libgd
git clone https://github.com/v2rayA/v2raya-openwrt.git package/v2raya-openwrt
git clone https://github.com/jerrykuku/luci-app-vssr.git package/luci-app-vssr
git clone https://github.com/jerrykuku/lua-maxminddb.git package/lua-maxminddb
git clone https://github.com/sbwml/luci-app-mosdns package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
git clone https://github.com/jlzsss/qBittorrent-Enhanced-Edition.git package/feeds/packages/qBittorrent-Enhanced-Edition



svn export --force https://github.com/coolsnowwolf/packages/branches/master/utils/mariadb package/feeds/packages/mariadb
svn export --force https://github.com/coolsnowwolf/packages/branches/master/utils/mariadb-common package/feeds/packages/mariadb-common
svn export --force https://github.com/coolsnowwolf/lede/branches/master/package/network/services/noddos package/feeds/packages/noddos
svn export --force https://github.com/coolsnowwolf/lede/branches/master/package/network/services/e2guardian package/feeds/packages/e2guardian
# svn export --force https://github.com/Joecaicai/openwrt-packages/trunk/luci-app-qbittorrent package/feeds/luci/luci-app-qbittorrent
# svn export --force https://github.com/JuanParker1/Packages/trunk/luci-app-qbittorrent package/feeds/luci/luci-app-qbittorrent
svn export --force https://github.com/kenzok8/jell/trunk/luci-app-qbittorrent package/feeds/luci/luci-app-qbittorrent
svn export --force https://github.com/kiddin9/openwrt-packages/trunk/luci-app-transmission package/feeds/luci/luci-app-transmission
svn export --force https://github.com/kiddin9/openwrt-packages/trunk/transmission package/feeds/packages/transmission
svn export --force https://github.com/kiddin9/openwrt-packages/trunk/transmission-web-control package/feeds/packages/transmission-web-control
# svn export --force https://github.com/kiddin9/openwrt-packages/trunk/luci-app-smartdns package/feeds/luci/luci-app-smartdns
# svn export --force https://github.com/kiddin9/openwrt-packages/trunk/smartdns package/feeds/packages/smartdns
svn export --force https://github.com/coolsnowwolf/packages/trunk/net/amule package/feeds/packages/amule
svn export --force https://github.com/openwrt/routing/branches/openwrt-19.07/cjdns package/feeds/routing/cjdns
svn export --force https://github.com/kenzok8/jell/branches/main/gost package/feeds/packages/gost
