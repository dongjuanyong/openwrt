include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=grub-efi

include ../common.mk

TAR_OPTIONS:= --transform 's/grub-${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}/' $(TAR_OPTIONS)

PKG_BUILD_DEPENDS:=grub2-efi/host

CONFIGURE_ARGS += --with-platform=efi
HOST_CONFIGURE_ARGS += --with-platform=efi --program-suffix=-efi
HOST_BUILD_DIR := $(BUILD_DIR_HOST)/$(PKG_NAME)-$(PKG_VERSION)

define Package/grub2-efi
$(call Package/grub2/Default)
HIDDEN:=1
TITLE += (with EFI support)
endef

define Host/Install
	$(call Host/Install/Default)

	$(INSTALL_DIR) $(STAGING_DIR_HOST)/lib/grub/grub2-efi
	$(STAGING_DIR_HOST)/bin/grub-mkimage-efi \
		-d $(STAGING_DIR_HOST)/lib/grub/x86_64-efi \
		-p /efi/boot \
		-O x86_64-efi \
		-c ./files/grub-efi.cfg \
		-o $(STAGING_DIR_HOST)/lib/grub/grub2-efi/bootx64.efi \
		boot chain configfile ext2 linux ls part_msdos reboot serial part_gpt search fat exfat efi_gop efi_uga gfxterm

	$(INSTALL_DIR) $(STAGING_DIR_HOST)/lib/grub/grub2-bios
	$(STAGING_DIR_HOST)/bin/grub-mkimage \
		-d $(STAGING_DIR_HOST)/lib/grub/i386-pc \
		-p '(hd0,gpt1)/boot/grub' \
		-O i386-pc \
		-c ./files/grub-efi.cfg \
		-o $(STAGING_DIR_HOST)/lib/grub/grub2-bios/core.img \
		biosdisk boot chain configfile ext2 linux ls part_msdos reboot serial vga part_gpt search fat exfat
endef

define Package/grub2-efi/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) ./files/grub-efi.cfg $(1)/etc
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,grub2-efi))
