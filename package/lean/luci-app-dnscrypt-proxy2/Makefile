# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-dnscrypt-proxy2
PKG_VERSION:=1.0
PKG_RELEASE:=10

define Package/$(PKG_NAME)/conffiles
/etc/config/dnscrypt-proxy2
/etc/dnscrypt-proxy2/addconf
endef

LUCI_TITLE:=LuCI support for dnscrypt-proxy 2
LUCI_DEPENDS:=+dnscrypt-proxy2
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature


