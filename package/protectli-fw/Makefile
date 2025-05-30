#
# Firmware blobs from Protectli Wi-Fi fix 0.3.1
#

include $(TOPDIR)/rules.mk

PKG_NAME:=protectli-fw
PKG_VERSION:=0.3.1
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://kb.protectli.com/wp-content/uploads/sites/9/2023/06
PKG_SOURCE:=wifi-fix-standalone-$(PKG_VERSION).tar.gz
PKG_HASH:=dad3dcb0fd08a546d45e4420c99b7d00496274bd7824a66dd3e5b65b2bba46ba

include $(INCLUDE_DIR)/package.mk

define Package/protectli-fw
  SECTION:=firmware
  CATEGORY:=Firmware
  TITLE:=Protectli QCA6174 Wi-Fi board/firmware blobs
endef

define Build/Compile
	# nothing to build - just copy blobs
endef

define Package/protectli-fw/install
	$(INSTALL_DIR) $(1)/lib/firmware/ath10k/QCA6174/hw3.0
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/wifi-fix-standalone/vendor/board-2.bin    \
		$(1)/lib/firmware/ath10k/QCA6174/hw3.0/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/wifi-fix-standalone/vendor/firmware-6.bin \
		$(1)/lib/firmware/ath10k/QCA6174/hw3.0/
endef

$(eval $(call BuildPackage,protectli-fw))
