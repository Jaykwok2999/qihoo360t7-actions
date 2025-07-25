#!/bin/bash
mkdir -p files/etc/config
wget -qO- https://raw.githubusercontent.com/Jaykwok2999/istoreos-ipk/refs/heads/main/patch/diy/openclash > files/etc/config/openclash
#wget -qO- https://raw.githubusercontent.com/Jaykwok2999/istoreos-ipk/refs/heads/main/patch/diy/proxy/openclash > files/etc/config/openclash
wget -qO- https://raw.githubusercontent.com/Jaykwok2999/istoreos-ipk/refs/heads/main/patch/diy/mosdns > files/etc/config/mosdns
wget -qO- https://raw.githubusercontent.com/Jaykwok2999/istoreos-ipk/refs/heads/main/patch/diy/smartdns > files/etc/config/smartdns
wget -qO- https://raw.githubusercontent.com/Jaykwok2999/istoreos-ipk/refs/heads/main/patch/diy/360t7/wireless  > files/etc/config/wireless


# 修改默认IP
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate
rm -rf include/version.mk
cp -af feeds/istoreos_ipk/patch/version.mk include/


# 修改默认密码
sed -i 's/root:::0:99999:7:::/root:$1$5mjCdAB1$Uk1sNbwoqfHxUmzRIeuZK1:0:0:99999:7:::/g' package/base-files/files/etc/shadow

##取消bootstrap为默认主题
sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci-nginx/Makefile

##加入作者信息
sed -i "s/DISTRIB_REVISION='*.*'/DISTRIB_REVISION=' By JayKwok'/g" package/base-files/files/etc/openwrt_release

# 移除要替换的包
rm -rf feeds/luci/applications/luci-app-upnp
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-openclash
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/istoreos_ipk/op-daed
rm -rf feeds/istoreos_ipk/patch/istoreos-files
rm -rf feeds/istoreos_ipk/vlmcsd
rm -rf feeds/istoreos_ipk/patch/wall-luci/luci-app-vlmcsd
rm -rf package/diy/luci-app-ota
rm -rf feeds/istoreos_ipk/linkease
# 移除 openwrt feeds 自带的核心库
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
git clone https://github.com/xiaorouji/openwrt-passwall-packages package/passwall-packages

# istoreos-theme
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/modules/luci-base/po/zh_Hans/base.po
cp -af feeds/istoreos_ipk/patch/zh_Hans/base.po feeds/luci/modules/luci-base/po/zh_Hans/
echo -e "\nmsgid \"Control\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "msgstr \"控制\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po

echo -e "\nmsgid \"NAS\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "msgstr \"网络存储\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po

echo -e "\nmsgid \"VPN\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "msgstr \"魔法网络\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

function merge_package() {
    # 参数1是分支名,参数2是库地址,参数3是所有文件下载到指定路径。
    # 同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开。
    if [[ $# -lt 3 ]]; then
        echo "Syntax error: [$#] [$*]" >&2
        return 1
    fi
    trap 'rm -rf "$tmpdir"' EXIT
    branch="$1" curl="$2" target_dir="$3" && shift 3
    rootdir="$PWD"
    localdir="$target_dir"
    [ -d "$localdir" ] || mkdir -p "$localdir"
    tmpdir="$(mktemp -d)" || exit 1
    git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$curl" "$tmpdir"
    cd "$tmpdir"
    git sparse-checkout init --cone
    git sparse-checkout set "$@"
    # 使用循环逐个移动文件夹
    for folder in "$@"; do
        mv -f "$folder" "$rootdir/$localdir"
    done
    cd "$rootdir"
}


rm -rf feeds/istoreos_ipk/luci-app-openclash
git_sparse_clone dev https://github.com/vernesong/OpenClash luci-app-openclash


git clone https://github.com/xiaorouji/openwrt-passwall-packages.git package/passwallpackages

# 更新 golang 1.25 版本
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang

# SSRP & Passwall
git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-passwall
cp -af feeds/istoreos_ipk/patch/un.svg package/luci-app-passwall/root/www/luci-static/passwall/flags/

# NTP
sed -i 's/0.openwrt.pool.ntp.org/ntp1.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/1.openwrt.pool.ntp.org/ntp2.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/2.openwrt.pool.ntp.org/time1.cloud.tencent.com/g' package/base-files/files/bin/config_generate
sed -i 's/3.openwrt.pool.ntp.org/time2.cloud.tencent.com/g' package/base-files/files/bin/config_generate

# 更改时间戳
rm -rf scripts/get_source_date_epoch.sh
cp -af feeds/istoreos_ipk/patch/get_source_date_epoch.sh scripts/
chmod +x scripts/get_source_date_epoch.sh

# 更改 banner
rm -rf package/base-files/files/etc/banner
cp -af feeds/istoreos_ipk/patch/banner package/base-files/files/etc/

# tailscale
rm -rf feeds/packages/net/tailscale
sed -i '/\/etc\/init\.d\/tailscale/d;/\/etc\/config\/tailscale/d;' feeds/packages/net/tailscale/Makefile



./scripts/feeds update -a
./scripts/feeds install -a
