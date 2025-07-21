#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
echo 'src-git diskman https://github.com/jjm2473/luci-app-diskman.git;dev' >>feeds.conf.default
echo 'src-git third_party https://github.com/linkease/istore-packages.git;main' >>feeds.conf.default
echo 'src-git jjm2473_apps https://github.com/jjm2473/openwrt-apps.git;main' >>feeds.conf.default
echo 'src-git istoreos_ipk https://github.com/Jaykwok2999/istoreos-ipk.git;main' >>feeds.conf.default  
echo 'src-git theme https://github.com/Jaykwok2999/istoreos-theme.git;main' >>feeds.conf.default
echo 'src-git turboacc https://github.com/chenmozhijin/turboacc.git;luci' >>feeds.conf.default
echo 'src-git socat https://github.com/Jaykwok2999/socat.git;main' >>feeds.conf.default
