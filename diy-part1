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
git clone https://github.com/kuoruan/openwrt-kcptun.git package/kcptun
git clone https://github.com/jlzsss/openwrt-miredo.git package/miredo
# git clone https://github.com/jlzsss/proxychains-ng.git package/proxychains-ng
git clone https://github.com/Mleaf/openwrt-mwol.git package/mwol
git clone https://github.com/yichya/luci-app-xray.git package/luci-app-xray
git clone https://github.com/yichya/openwrt-xray.git package/openwrt-xray
git clone -b legacy https://github.com/jlzsss/luci-app-v2ray.git package/luci-app-v2ray
git clone https://github.com/frainzy1477/luci-app-trojan.git package/luci-app-trojan
git clone -b test https://github.com/frainzy1477/luci-app-clash.git package/luci-app-clash
git clone -b master https://github.com/vernesong/OpenClash.git package/OpenClash
git clone https://github.com/project-openwrt/luci-app-koolproxyR.git package/luci-app-koolproxyR
git clone https://github.com/fw876/helloworld.git package/helloworld
# git clone https://github.com/jlzsss/luci-app-ssr-plus-Jo.git package/luci-app-ssr-plus-Jo
# git clone https://github.com/jlzsss/luci-app-ssr-plus-jo-depend.git package/luci-app-ssr-plus-jo-depend
# svn co https://github.com/openwrt/packages/trunk/libs/libcap package/feeds/packages/libcap
svn co https://github.com/Lienol/openwrt/trunk/package/diy package/diy
# svn co https://github.com/Lienol/openwrt-packages/trunk/utils/dockerd package/diy/dockerd
rm -rf package/diy/luci-app-dockerman
rm -rf package/diy/OpenAppFilter
rm -rf package/lean/luci-theme-argon
git clone https://github.com/kuoruan/openwrt-v2ray.git package/v2ray-core
git clone -b master --depth 1 https://github.com/kuoruan/openwrt-upx.git package/openwrt-upx
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
git clone https://github.com/jlzsss/php7.git package/feeds/packages/php7
# git clone https://github.com/jlzsss/docker-ce.git package/docker-ce
# git clone https://gitee.com/wangfuying_admin/Docker-For-OpenWRT.git package/docker
git clone https://github.com/lisaac/luci-app-dockerman.git package/luci-app-dockerman
git clone https://github.com/NateLol/luci-app-oled.git package/luci-app-oled
# svn co https://github.com/Lienol/openwrt-packages/trunk/lang/python package/feeds/packages/python
# svn co https://github.com/Lienol/openwrt-packages/trunk/utils/docker-ce package/feeds/packages/docker-ce
git clone https://github.com/jlzsss/dnscrypt-proxy2.git package/feeds/packages/dnscrypt-proxy2
git clone https://github.com/jlzsss/smartdns.git package/feeds/packages/smartdns
git clone https://github.com/jlzsss/luci-app-smartdns.git package/feeds/luci/luci-app-smartdns
# svn co https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-transmission package/feeds/luci/luci-app-transmission
