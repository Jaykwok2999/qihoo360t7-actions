#!/bin/bash
#=================================================

sed -i "1isrc-git 2h69k_oled https://github.com/jjm2473/luci-app-oled.git;master\n" feeds.conf.default
sed -i "2isrc-git diskman https://github.com/jjm2473/luci-app-diskman.git;dev\n" feeds.conf.default
sed -i "3isrc-git oaf https://github.com/jjm2473/OpenAppFilter.git;dev6\n" feeds.conf.default
sed -i "4isrc-git jjm2473_apps https://github.com/jjm2473/openwrt-apps.git;main\n" feeds.conf.default
sed -i "5isrc-git istoreos_ipk https://github.com/Jaykwok2999/istoreos-ipk.git;main\n" feeds.conf.default
sed -i "6isrc-git theme https://github.com/Jaykwok2999/istoreos-theme.git;main\n" feeds.conf.default
sed -i "7isrc-git third_party https://github.com/linkease/istore-packages.git;main\n" feeds.conf.default
sed -i "8isrc-git socat https://github.com/Jaykwok2999/socat.git;main\n" feeds.conf.default
