#!/bin/bash
mkdir -p files/etc/config
wget -qO- https://raw.githubusercontent.com/Jaykwok2999/istoreos-ipk/refs/heads/main/patch/diy/openclash > files/etc/config/openclash
wget -qO- https://raw.githubusercontent.com/Jaykwok2999/istoreos-ipk/refs/heads/main/patch/diy/mosdns > files/etc/config/mosdns
wget -qO- https://raw.githubusercontent.com/Jaykwok2999/istoreos-ipk/refs/heads/main/patch/diy/smartdns > files/etc/config/smartdns


# 修改默认IP
sed -i 's/192.168.100.1/192.168.5.1/g' package/istoreos-files/Makefile
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate

# TTYD
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json

# 修改默认密码
sed -i 's/root:::0:99999:7:::/root:$1$5mjCdAB1$Uk1sNbwoqfHxUmzRIeuZK1:0:0:99999:7:::/g' package/base-files/files/etc/shadow

# iStoreOS-settings
git clone --depth=1 -b main https://github.com/Jaykwok2999/istoreos-settings package/default-settings

##取消bootstrap为默认主题
sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci-nginx/Makefile

# mwan3
sed -i 's/MultiWAN 管理器/负载均衡/g' feeds/luci/applications/luci-app-mwan3/po/zh_Hans/mwan3.po

# samba4
sed -i 's/services/nas/g' feeds/luci/applications/luci-app-samba4/root/usr/share/luci/menu.d/luci-app-samba4.json

# linkease调至NAS
sed -i 's/services/nas/g' feeds/nas-packages-luci/luci/luci-app-linkease/luasrc/controller/linkease.lua
sed -i 's/services/nas/g' feeds/nas-packages-luci/luci/luci-app-linkease/luasrc/view/linkease_status.htm

# upnp调至NAS
sed -i 's/services/nas/g' feeds/luci/applications/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json

# Alist调至NAS
sed -i 's/services/nas/g' feeds/luci/applications/luci-app-alist/root/usr/share/luci/menu.d/luci-app-alist.json
sed -i 's/msgstr "AList"/msgstr "AList文件列表"/g' feeds/luci/applications/luci-app-alist/po/zh_Hans/alist.po
sed -i 's/msgstr "AList"/msgstr "AList文件列表"/g' feeds/luci/applications/luci-app-alist/po/zh_Hant/alist.po

# HD磁盘工具调至NAS
sed -i 's/services/nas/g' feeds/luci/applications/luci-app-hd-idle/root/usr/share/luci/menu.d/luci-app-hd-idle.json

# 修改FileBrowser
sed -i 's/msgstr "FileBrowser"/msgstr "文件浏览器"/g' feeds/istoreos_ipk/op-fileBrowser/luci-app-filebrowser/po/zh_Hans/filebrowser.po
sed -i 's/services/nas/g' feeds/istoreos_ipk/op-fileBrowser/luci-app-filebrowser/root/usr/share/luci/menu.d/luci-app-filebrowser.json

##加入作者信息
sed -i "s/DISTRIB_DESCRIPTION='*.*'/DISTRIB_DESCRIPTION='iStoreOS-$(date +%Y%m%d%M)'/g"  package/base-files/files/etc/openwrt_release
sed -i "s/DISTRIB_REVISION='*.*'/DISTRIB_REVISION=' By JayKwok'/g" package/base-files/files/etc/openwrt_release

# 移除要替换的包
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box}
# rm -rf feeds/packages/net/alist feeds/luci/applications/luci-app-alist
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/third_party/luci-app-LingTiGameAcc
rm -rf feeds/third_party/luci-app-socat
rm -rf feeds/istoreos_ipk/op-daed
rm -rf feeds/istoreos_ipk/patch/istoreos-files
rm -rf feeds/istoreos_ipk/vlmcsd
rm -rf feeds/istoreos_ipk/patch/wall-luci/luci-app-vlmcsd



# istoreos-theme
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/third/luci-theme-argon
rm -rf feeds/third/luci-app-argon-config
rm -rf feeds/istoreos_ipk/theme/luci-theme-argon
#rm -rf feeds/istoreos_ipk/theme/luci-app-argon-config

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

git_sparse_clone main https://github.com/Jaykwok2999/socat luci-app-socat


# golong1.24.2依赖
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

# SSRP & Passwall
git clone https://github.com/Jaykwok2999/luci-app-passwall.git package/passwall -b main
rm -rf feeds/istoreos_ipk/patch/wall-luci/luci-app-passwall


# unzip
rm -rf feeds/packages/utils/unzip
git clone https://github.com/sbwml/feeds_packages_utils_unzip feeds/packages/utils/unzip

# frpc名称
sed -i 's,发送,Transmission,g' feeds/luci/applications/luci-app-transmission/po/zh_Hans/transmission.po
sed -i 's,frp 服务器,frps 服务器,g' feeds/luci/applications/luci-app-frps/po/zh_Hans/frps.po
sed -i 's,frp 客户端,frpc 客户端,g' feeds/luci/applications/luci-app-frpc/po/zh_Hans/frpc.po

# 必要的补丁
pushd feeds/luci
   curl -s https://raw.githubusercontent.com/oppen321/path/refs/heads/main/Firewall/0001-luci-mod-status-firewall-disable-legacy-firewall-rul.patch | patch -p1
popd

pushd
   curl -sSL https://raw.githubusercontent.com/Jaykwok2999/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh
popd

#pushd
#   curl -sSL https://raw.githubusercontent.com/Jaykwok2999/qihoo360t7-actions/refs/heads/main/devices/mediatek_filogic/patches/01-360t7.patch | patch -p1
#popd

# NTP
sed -i 's/0.openwrt.pool.ntp.org/ntp1.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/1.openwrt.pool.ntp.org/ntp2.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/2.openwrt.pool.ntp.org/time1.cloud.tencent.com/g' package/base-files/files/bin/config_generate
sed -i 's/3.openwrt.pool.ntp.org/time2.cloud.tencent.com/g' package/base-files/files/bin/config_generate

# 更改 banner
rm -rf package/base-files/files/etc/banner
cp -af feeds/istoreos_ipk/patch/istoreos-24.10/banner package/base-files/files/etc/

# tailscale
rm -rf feeds/packages/net/tailscale
sed -i '/\/etc\/init\.d\/tailscale/d;/\/etc\/config\/tailscale/d;' feeds/packages/net/tailscale/Makefile

# 增加驱动补丁
cp -af feeds/istoreos_ipk/patch/diy/patches-6.6/996-intel-igc-i225-i226-disable-eee.patch target/linux/x86/patches-6.6/

./scripts/feeds update -a
./scripts/feeds install -a
