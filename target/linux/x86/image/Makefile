#
# Copyright (C) 2006-2020 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

GRUB2_VARIANT =
GRUB_TERMINALS =
GRUB_SERIAL_CONFIG =
GRUB_TERMINAL_CONFIG =
GRUB_CONSOLE_CMDLINE =

ifneq ($(strip $(foreach subtarget,$(USE_ATKBD),$(CONFIG_TARGET_x86_$(subtarget)))),)
  GRUB2_VARIANT := generic
else
  GRUB2_VARIANT := legacy
endif

ifneq ($(CONFIG_GRUB_CONSOLE),)
  GRUB_CONSOLE_CMDLINE += console=tty0
  GRUB_TERMINALS += console
endif

GRUB_SERIAL:=$(call qstrip,$(CONFIG_GRUB_SERIAL))

ifneq ($(GRUB_SERIAL),)
  GRUB_CONSOLE_CMDLINE += console=$(GRUB_SERIAL),$(CONFIG_GRUB_BAUDRATE)n8$(if $(CONFIG_GRUB_FLOWCONTROL),r,)
  GRUB_SERIAL_CONFIG := serial --unit=0 --speed=$(CONFIG_GRUB_BAUDRATE) --word=8 --parity=no --stop=1 --rtscts=$(if $(CONFIG_GRUB_FLOWCONTROL),on,off)
  GRUB_TERMINALS += serial
endif

ifneq ($(GRUB_TERMINALS),)
  GRUB_TERMINAL_CONFIG := terminal_input $(GRUB_TERMINALS); terminal_output $(GRUB_TERMINALS)
endif

ROOTPART:=$(call qstrip,$(CONFIG_TARGET_ROOTFS_PARTNAME))
ROOTPART:=$(if $(ROOTPART),$(ROOTPART),PARTUUID=$(IMG_PART_SIGNATURE)-02)
EFI_SIGNATURE:=$(strip $(shell uuidgen | sed "s/[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]$$/0002/" | tr '[a-z]' '[A-Z]'))

GRUB_TIMEOUT:=$(call qstrip,$(CONFIG_GRUB_TIMEOUT))
GRUB_TITLE:=$(call qstrip,$(CONFIG_GRUB_TITLE))

BOOTOPTS:=$(call qstrip,$(CONFIG_GRUB_BOOTOPTS))

define Build/combined
	$(CP) $(KDIR)/$(KERNEL_NAME) $@.boot/boot/vmlinuz
	-$(CP) $(STAGING_DIR_ROOT)/boot/. $@.boot/boot/
	PADDING="1" SIGNATURE="$(IMG_PART_SIGNATURE)" $(SCRIPT_DIR)/gen_image_generic.sh \
		$@ \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) $@.boot \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(IMAGE_ROOTFS) \
		256
endef

define Build/grub-config
	rm -fR $@.boot
	$(INSTALL_DIR) $@.boot/boot/grub
	sed \
		-e 's#@SERIAL_CONFIG@#$(strip $(GRUB_SERIAL_CONFIG))#g' \
		-e 's#@TERMINAL_CONFIG@#$(strip $(GRUB_TERMINAL_CONFIG))#g' \
		-e 's#@ROOTPART@#root=$(ROOTPART) rootwait#g' \
		-e 's#@CMDLINE@#$(BOOTOPTS) $(GRUB_CONSOLE_CMDLINE)#g' \
		-e 's#@TIMEOUT@#$(GRUB_TIMEOUT)#g' \
		-e 's#@TITLE@#$(GRUB_TITLE)#g' \
		./grub-$(1).cfg > $@.boot/boot/grub/grub.cfg
endef

define Build/grub-install
	rm -fR $@.grub2
	$(INSTALL_DIR) $@.grub2
	$(CP) $(STAGING_DIR_HOST)/lib/grub/i386-pc/*.img \
		$(STAGING_DIR_HOST)/lib/grub/grub2-$(GRUB2_VARIANT)/core.img \
		$@.grub2/
	echo '(hd0) $@' > $@.grub2/device.map
	$(STAGING_DIR_HOST)/bin/grub-bios-setup \
		-m "$@.grub2/device.map" \
		-d "$@.grub2" \
		-r "hd0,msdos1" \
		$@
endef

define Build/iso
	$(CP) $(KDIR)/$(KERNEL_NAME) $@.boot/boot/vmlinuz
	cat \
		$(STAGING_DIR_HOST)/lib/grub/i386-pc/cdboot.img \
		$(STAGING_DIR_HOST)/lib/grub/grub2-iso/eltorito.img \
		> $@.boot/boot/grub/eltorito.img
	-$(CP) $(STAGING_DIR_ROOT)/boot/. $@.boot/boot/
	mkisofs -R -b boot/grub/eltorito.img -no-emul-boot -boot-info-table \
		-o $@ $@.boot $(TARGET_DIR)
endef

ifneq ($(CONFIG_EFI_SIGNED_BINARY),)

  define Build/Sign
  	cd $(TOPDIR) && \
  	echo "Checking certificate information" && \
  	openssl x509 -in $(CONFIG_EFI_SIGNING_PUBLIC_KEY) -text -noout && \
  	echo "Signing kernel" && \
  	sbsign --cert $(CONFIG_EFI_SIGNING_PUBLIC_KEY) \
  		--key $(CONFIG_EFI_SIGNING_PRIVATE_KEY) \
  		$@.boot/boot/vmlinuz && \
  	rm -f $@.boot/boot/vmlinuz && \
  	mv $@.boot/boot/vmlinuz.signed $@.boot/boot/vmlinuz && \
  	echo "Verifying kernel signature" && \
  	sbverify --list \
  		$@.boot/boot/vmlinuz && \
  	sbverify --cert $(CONFIG_EFI_SIGNING_PUBLIC_KEY) \
  		$@.boot/boot/vmlinuz && \
  	echo "Signing bootloader" && \
  	sbsign --cert $(CONFIG_EFI_SIGNING_PUBLIC_KEY) \
  		--key $(CONFIG_EFI_SIGNING_PRIVATE_KEY) \
  		$(KDIR)/grub2.efi/efi/boot/bootx64.efi && \
  	rm -f $(KDIR)/grub2.efi/efi/boot/bootx64.efi && \
  	mv $(KDIR)/grub2.efi/efi/boot/bootx64.efi.signed $(KDIR)/grub2.efi/efi/boot/bootx64.efi && \
  	echo "Verifying bootloader signature" && \
  	sbverify --list \
  		$(KDIR)/grub2.efi/efi/boot/bootx64.efi && \
  	sbverify --cert $(CONFIG_EFI_SIGNING_PUBLIC_KEY) \
  		$(KDIR)/grub2.efi/efi/boot/bootx64.efi && \
  	echo "Signing kernel and bootloader complete" && \
  	cd -
  endef

else

  define Build/Sign
  	echo "Not signing efi binaries"
  endef

endif

define Build/efi
	rm -fR $@.boot
	$(INSTALL_DIR) $@.boot/boot/grub
	sed \
		-e 's#@SERIAL_CONFIG@#$(strip $(GRUB_SERIAL_CONFIG))#g' \
		-e 's#@TERMINAL_CONFIG@#$(strip $(GRUB_TERMINAL_CONFIG))#g' \
		-e 's#@ROOTPART@#root=PARTUUID=$(EFI_SIGNATURE) rootwait#g' \
		-e 's#@CMDLINE@#$(BOOTOPTS) $(GRUB_CONSOLE_CMDLINE)#g' \
		-e 's#@TIMEOUT@#$(GRUB_TIMEOUT)#g' \
		-e 's#@TITLE@#$(GRUB_TITLE)#g' \
		-e 's#set root.*#search --file /boot/grub/grub.cfg --set=root#g' \
		./grub-pc.cfg > $@.boot/boot/grub/grub.cfg
	$(CP) $(KDIR)/$(KERNEL_NAME) $@.boot/boot/vmlinuz
	-$(CP) $(STAGING_DIR_ROOT)/boot/. $@.boot/boot/

	rm -rf $(KDIR)/grub2.efi/ || true
	$(INSTALL_DIR) $(KDIR)/grub2.efi/efi/boot/
	$(CP) $(STAGING_DIR_HOST)/lib/grub/grub2-efi/bootx64.efi \
		$(KDIR)/grub2.efi/efi/boot/
	$(call Build/Sign)
	rm $(KDIR)/kernel.efi || true
	mkfs.fat -C $(KDIR)/kernel.efi -S 512 1024
	mcopy -s -i "$(KDIR)/kernel.efi" $(KDIR)/grub2.efi/* ::/
	SIGNATURE="$(IMG_PART_SIGNATURE)" PATH="$(TARGET_PATH)" ./gen_image_efi.sh \
		$@ \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) $@.boot \
		1 $(KDIR)/kernel.efi \
		1 \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(IMAGE_ROOTFS) \
		1024
	dd if=/dev/zero of=$@ bs=512 count=34 conv=notrunc oflag=append
	sgdisk -g $@
	sgdisk -t 2:EF00 $@
	sgdisk -t 3:EF02 $@
	sgdisk -u 4:$(EFI_SIGNATURE) $@
	sgdisk -h $@

	rm -fR $@.grub2
	$(INSTALL_DIR) $@.grub2
	$(CP) $(STAGING_DIR_HOST)/lib/grub/i386-pc/*.img \
		$(STAGING_DIR_HOST)/lib/grub/grub2-bios/core.img \
		$@.grub2/
	echo '(hd0) $@' > $@.grub2/device.map
	$(STAGING_DIR_HOST)/bin/grub-bios-setup-efi \
		-m "$@.grub2/device.map" \
		-d "$@.grub2" \
		-r "hd0,gpt1" \
		$@
endef

DEVICE_VARS += GRUB2_VARIANT
define Device/Default
  ARTIFACT/image.iso := grub-config iso | iso
  IMAGE/combined.img := grub-config pc | combined | grub-install
  IMAGE/combined.img.gz := grub-config pc | combined | grub-install | gzip
  IMAGE/combined.vdi := grub-config pc | combined | grub-install | qemu-image vdi
  IMAGE/combined.vmdk := grub-config pc | combined | grub-install | qemu-image vmdk
  IMAGE/rootfs.img := append-rootfs
  IMAGE/rootfs.img.gz := append-rootfs | gzip
  IMAGE/uefi-gpt.img := efi
  IMAGE/uefi-gpt.img.gz := efi | gzip
  ifeq ($(CONFIG_TARGET_IMAGES_GZIP),y)
    IMAGES := rootfs.img.gz
    ifeq ($(CONFIG_GRUB_IMAGES),y)
      IMAGES += combined.img.gz
    endif
    ifeq ($(CONFIG_EFI_IMAGES),y)
      IMAGES += uefi-gpt.img.gz
    endif
  else
    IMAGES := rootfs.img
    ifeq ($(CONFIG_GRUB_IMAGES),y)
      IMAGES += combined.img
    endif
    ifeq ($(CONFIG_EFI_IMAGES),y)
      IMAGES += uefi-gpt.img
    endif
  endif
  KERNEL := kernel-bin
  KERNEL_INSTALL := 1
  KERNEL_NAME := bzImage
  ifeq ($(CONFIG_ISO_IMAGES),y)
    ARTIFACTS := image.iso
  endif
  ifeq ($(CONFIG_VDI_IMAGES),y)
    IMAGES += combined.vdi
  endif
  ifeq ($(CONFIG_VMDK_IMAGES),y)
    IMAGES += combined.vmdk
  endif
endef

$(eval $(call Image/gzip-ext4-padded-squashfs))

ifeq ($(SUBTARGET),64)
  include 64.mk
endif

ifeq ($(SUBTARGET),generic)
  include generic.mk
endif

ifeq ($(SUBTARGET),geode)
  include geode.mk
endif

ifeq ($(SUBTARGET),legacy)
  include legacy.mk
endif

$(eval $(call BuildImage))
