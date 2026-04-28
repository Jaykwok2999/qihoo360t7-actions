#!/bin/bash
#=================================================
# JayKwok's script
#=================================================
##添加自己的插件库
sed -i "1isrc-git istoreos_ipk https://github.com/Jaykwok2999/istoreos-ipk.git;main\n" feeds.conf.default        
sed -i "2isrc-git nas_luci https://github.com/Jaykwok2999/linkease.git;main\n" feeds.conf.default        
#sed -i "3isrc-git turboacc https://github.com/chenmozhijin/turboacc.git;luci\n" feeds.conf.default        
#sed -i "4isrc-git turboaccpackage https://github.com/chenmozhijin/turboacc.git;package\n" feeds.conf.default        
sed -i "5isrc-git theme https://github.com/Jaykwok2999/openwrt-theme.git;main\n" feeds.conf.default
