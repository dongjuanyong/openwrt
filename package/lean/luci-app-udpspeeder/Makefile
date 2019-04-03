#
# Copyright (C) 2016-2017 Jian Chang <aa65535@live.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-udpspeeder
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jian Chang <aa65535@live.com>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI Support for UDPspeeder
	PKGARCH:=all
	DEPENDS:=+udpspeeder
endef

define Package/$(PKG_NAME)/description
	LuCI Support for UDPspeeder.
endef

define Build/Prepare
	$(foreach po,$(wildcard ${CURDIR}/files/luci/i18n/*.po), \
		po2lmo $(po) $(PKG_BUILD_DIR)/$(patsubst %.po,%.lmo,$(notdir $(po)));)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	( . /etc/uci-defaults/luci-udpspeeder ) && rm -f /etc/uci-defaults/luci-udpspeeder
fi
exit 0
endef

define Package/$(PKG_NAME)/conffiles
	/etc/config/udpspeeder
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/udpspeeder.*.lmo $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/luci/controller/*.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/udpspeeder
	$(INSTALL_DATA) ./files/luci/model/cbi/udpspeeder/*.lua $(1)/usr/lib/lua/luci/model/cbi/udpspeeder/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/udpspeeder
	$(INSTALL_DATA) ./files/luci/view/udpspeeder/*.htm $(1)/usr/lib/lua/luci/view/udpspeeder/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/root/etc/config/udpspeeder $(1)/etc/config/udpspeeder
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/root/etc/init.d/udpspeeder $(1)/etc/init.d/udpspeeder
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/root/etc/uci-defaults/luci-udpspeeder $(1)/etc/uci-defaults/luci-udpspeeder
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
