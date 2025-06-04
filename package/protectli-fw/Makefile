#
# Firmware blobs from Protectli Wi-Fi fix 0.3.1
#

include $(TOPDIR)/rules.mk

PKG_NAME:=protectli-fw
PKG_VERSION:=0.3.1
PKG_RELEASE:=1

PKG_SOURCE:=wifi-fix-standalone-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://kb.protectli.com/wp-content/uploads/sites/9/2023/06
PKG_HASH:=dad3dcb0fd08a546d45e4420c99b7d00496274bd7824a66dd3e5b65b2bba46ba

PKG_SOURCE_SUBDIR:=wifi-fix-standalone
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=firmware
  CATEGORY:=Firmware
  TITLE:=Protectli QCA6174 Wi-Fi board / firmware blobs
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/lib/firmware/ath10k/QCA6174/hw3.0
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/vendor/board-2.bin \
		$(1)/lib/firmware/ath10k/QCA6174/hw3.0/
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/vendor/firmware-6.bin \
		$(1)/lib/firmware/ath10k/QCA6174/hw3.0/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
