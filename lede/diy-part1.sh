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
git clone https://github.com/xiechangan123/luci-i18n-xray-zh-cn.git package/luci-i18n-xray-zh-cn
git clone https://github.com/yichya/openwrt-xray-geodata-cut.git package/xray-geodata
git clone -b luci2 https://github.com/jlzsss/luci-app-v2ray.git package/luci-app-v2ray
git clone https://github.com/frainzy1477/luci-app-trojan.git package/luci-app-trojan
git clone -b test https://github.com/frainzy1477/luci-app-clash.git package/luci-app-clash
git clone https://github.com/sirpdboy/netspeedtest.git package/netspeedtest
git clone https://github.com/lisaac/luci-app-dockerman.git package/luci-app-dockerman
git clone https://github.com/xiaorouji/openwrt-passwall-packages package/passwall-packages
git clone https://github.com/xiaorouji/openwrt-passwall package/passwall
git clone https://github.com/xiaorouji/openwrt-passwall2 package/passwall2
git clone https://github.com/Thaolga/openwrt-nekobox package/openwrt-nekobox
# git clone https://github.com/project-openwrt/luci-app-koolproxyR.git package/luci-app-koolproxyR
git clone -b master --depth 1 https://github.com/vernesong/OpenClash.git package/OpenClash
# svn co https://github.com/Lienol/openwrt/trunk/package/diy package/diy
# rm -rf package/diy/luci-app-dockerman
# rm -rf package/diy/OpenAppFilter
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
git clone https://github.com/NateLol/luci-app-oled.git package/luci-app-oled
git clone https://github.com/jlzsss/dnscrypt-proxy2.git package/feeds/packages/dnscrypt-proxy2
# git clone https://github.com/immortalwrt-collections/openwrt-cdnspeedtest.git package/openwrt-cdnspeedtest
git clone https://github.com/jlzsss/luci-app-cloudflarespeedtest.git package/luci-app-cloudflarespeedtest
# git clone https://github.com/jlzsss/smartdns.git package/feeds/packages/smartdns
# git clone https://github.com/jlzsss/luci-app-smartdns.git package/feeds/luci/luci-app-smartdns
git clone https://github.com/jlzsss/libgd.git package/feeds/packages/libgd
git clone https://github.com/v2rayA/v2raya-openwrt.git package/v2raya-openwrt
# git clone https://github.com/jlzsss/v2raya-openwrt.git package/v2raya-openwrt
git clone https://github.com/sbwml/luci-app-mosdns package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
git clone https://github.com/OpenWrt-Actions/luci-app-vssr.git package/luci-app-vssr
git clone https://github.com/jerrykuku/lua-maxminddb.git package/lua-maxminddb
git clone https://github.com/jlzsss/luci-app-qbittorrent.git package/luci-app-qbittorrent
# git clone --depth 1 --filter=blob:none --sparse https://github.com/xiaorouji/openwrt-passwall-packages.git temp-lede && cd temp-lede && git sparse-checkout set geoview && cd .. && mkdir -p package/geoview && mv temp-lede/geoview package/ && rm -rf temp-lede
git clone --depth 1 --filter=blob:none --sparse https://github.com/coolsnowwolf/lede.git temp-lede && cd temp-lede && git sparse-checkout set package/libs/pcre && cd .. && mkdir -p package/pcre && mv temp-lede/package/libs/pcre package/pcre && rm -rf temp-lede
# git clone https://github.com/jlzsss/qBittorrent-Enhanced-Edition.git package/feeds/packages/qBittorrent-Enhanced-Edition
