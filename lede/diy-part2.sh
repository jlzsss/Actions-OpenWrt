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

# rm -rf feeds/packages2/lang/python
rm -rf feeds/small/geoview
rm -rf feeds/kenzok8/geoview
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang
git clone --depth 1 --filter=blob:none --sparse https://github.com/immortalwrt/packages.git temp-lede && cd temp-lede && git sparse-checkout set net/uwsgi && cd .. && rm -rf feeds/packages/net/uwsgi && mv temp-lede/net/uwsgi feeds/packages/net && rm -rf temp-lede
# git clone --depth 1 --filter=blob:none --sparse https://github.com/coolsnowwolf/packages.git temp-lede && cd temp-lede && git sparse-checkout set lang/rust && cd .. && rm -rf feeds/packages/lang/rust && mv temp-lede/lang/rust feeds/packages/lang && rm -rf temp-lede
