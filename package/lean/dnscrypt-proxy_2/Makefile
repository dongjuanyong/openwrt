#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dnscrypt-proxy_2
PKG_VERSION:=2.0.22
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=DNS proxy with support for encrypted DNS protocols
	URL:=https://github.com/jedisct1/dnscrypt-proxy
endef

define Package/$(PKG_NAME)/description
A flexible DNS proxy, with support for modern encrypted DNS protocols such as DNSCrypt v2 and DNS-over-HTTPS.
endef

PKG_ARCH:=$(ARCH)
ifeq ($(ARCH),aarch64)
	PKG_ARCH:=arm64
endif

PKG_BIN:=dnscrypt-proxy

define Build/Prepare
	[ ! -f $(PKG_BUILD_DIR)/$(PKG_BIN)-linux_$(PKG_ARCH)-$(PKG_VERSION).tar.gz ] && wget https://github.com/jedisct1/$(PKG_BIN)/releases/download/$(PKG_VERSION)/$(PKG_BIN)-linux_$(PKG_ARCH)-$(PKG_VERSION).tar.gz -O $(PKG_BUILD_DIR)/$(PKG_BIN)-linux_$(PKG_ARCH)-$(PKG_VERSION).tar.gz
	tar -xzf $(PKG_BUILD_DIR)/$(PKG_BIN)-linux_$(PKG_ARCH)-$(PKG_VERSION).tar.gz -C $(PKG_BUILD_DIR)
	[ ! -f $(PKG_BUILD_DIR)/public-resolvers.md ] && wget https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v2/public-resolvers.md -O $(PKG_BUILD_DIR)/public-resolvers.md
	[ ! -f $(PKG_BUILD_DIR)/public-resolvers.md.minisig ] && wget https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v2/public-resolvers.md.minisig -O $(PKG_BUILD_DIR)/public-resolvers.md.minisig
endef

define Build/Compile
	chmod +x $(PKG_BUILD_DIR)/linux-$(PKG_ARCH)/$(PKG_BIN) && upx --lzma $(PKG_BUILD_DIR)/linux-$(PKG_ARCH)/$(PKG_BIN)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/linux-$(PKG_ARCH)/$(PKG_BIN) $(1)/usr/bin/$(PKG_BIN)
	$(INSTALL_DIR) $(1)/etc/$(PKG_BIN)
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/public-resolvers.md $(1)/etc/$(PKG_BIN)/public-resolvers.md
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/public-resolvers.md.minisig $(1)/etc/$(PKG_BIN)/public-resolvers.md.minisig
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
