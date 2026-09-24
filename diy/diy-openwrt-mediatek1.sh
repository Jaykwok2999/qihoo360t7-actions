#!/bin/bash
#=================================================
# JayKwok's script
#=================================================
##添加自己的插件库
sed -i '1i src-git istoreos_ipk https://github.com/Jaykwok2999/istoreos-ipk.git;main' feeds.conf.default        
sed -i '2i src-git nas_luci https://github.com/Jaykwok2999/linkease.git;main' feeds.conf.default        
#sed -i '3i src-git turboacc https://github.com/chenmozhijin/turboacc.git;luci' feeds.conf.default        
#sed -i '4i src-git turboaccpackage https://github.com/chenmozhijin/turboacc.git;package' feeds.conf.default        
sed -i '5i src-git theme https://github.com/Jaykwok2999/openwrt-theme.git;main' feeds.conf.default
