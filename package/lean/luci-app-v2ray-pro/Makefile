# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for V2Ray
LUCI_DEPENDS:=+iptables-mod-tproxy +kmod-ipt-tproxy +ip +ipset-lists \
	+pdnsd-alt +coreutils +coreutils-base64 +coreutils-nohup +dnsmasq-full \
	+xray-core +ca-certificates +lua-cjson +luci-app-dnscrypt-proxy2 \
	+(!XRAY_CORE_PROVIDE_V2RAY_CORE):v2ray
LUCI_PKGARCH:=all
PKG_VERSION:=2.0
PKG_RELEASE:=2

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
