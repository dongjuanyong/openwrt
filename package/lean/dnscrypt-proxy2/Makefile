#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dnscrypt-proxy2
PKG_VERSION:=2.0.25
PKG_RELEASE:=1

PKG_BIN:=dnscrypt-proxy
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_BIN)-$(PKG_VERSION)

PKG_SOURCE:=$(PKG_BIN)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/jedisct1/dnscrypt-proxy/tar.gz/$(PKG_VERSION)?
PKG_HASH:=774696004c9e306e1723b4cbbe66a961128a335543d318d0786492ce69b906fa

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/jedisct1/dnscrypt-proxy

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=IP Addresses and Names
	TITLE:=DNS proxy with support for encrypted DNS protocols
	URL:=https://github.com/jedisct1/dnscrypt-proxy
	DEPENDS:=$$(GO_ARCH_DEPENDS)
endef

define Package/$(PKG_NAME)/description
A flexible DNS proxy, with support for modern encrypted DNS protocols such as DNSCrypt v2 and DNS-over-HTTPS.
endef

define Package/golang-github-jedisct1-dnscrypt-proxy-dev
	TITLE:=DNS proxy with support for encrypted DNS protocols (source files)
	URL:=https://github.com/jedisct1/dnscrypt-proxy
$(call GoPackage/GoSubMenu)
	PKGARCH:=all
endef

define Package/golang-github-jedisct1-dnscrypt-proxy-dev/description
$(call Package/dnscrypt-proxy2/description)

This package provides the source files for the dnscrypt-proxy.
endef

define Build/Compile
$(call GoPackage/Build/Compile,-ldflags "-s -w")
	chmod +x $$(GO_PKG_BUILD_BIN_DIR)/$$(PKG_BIN) && upx --lzma $$(GO_PKG_BUILD_BIN_DIR)/$$(PKG_BIN)
	[ ! -f $$(PKG_BUILD_DIR)/public-resolvers.md ] && wget https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v2/public-resolvers.md -O $$(PKG_BUILD_DIR)/public-resolvers.md
	[ ! -f $$(PKG_BUILD_DIR)/public-resolvers.md.minisig ] && wget https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v2/public-resolvers.md.minisig -O $$(PKG_BUILD_DIR)/public-resolvers.md.minisig
endef

define Package/$(PKG_NAME)/install
	$$(INSTALL_DIR) $(1)/usr/bin
	$$(INSTALL_BIN) $$(GO_PKG_BUILD_BIN_DIR)/$$(PKG_BIN) $(1)/usr/bin/$$(PKG_BIN)
	$$(INSTALL_DIR) $(1)/etc/$$(PKG_BIN)
	$$(INSTALL_DATA) $$(PKG_BUILD_DIR)/public-resolvers.md $(1)/etc/$$(PKG_BIN)/public-resolvers.md
	$$(INSTALL_DATA) $$(PKG_BUILD_DIR)/public-resolvers.md.minisig $(1)/etc/$$(PKG_BIN)/public-resolvers.md.minisig
endef

$(eval $(call GoBinPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))

$(eval $(call GoSrcPackage,golang-github-jedisct1-dnscrypt-proxy-dev))
$(eval $(call BuildPackage,golang-github-jedisct1-dnscrypt-proxy-dev))
