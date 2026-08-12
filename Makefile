# Shook framework — Theos xcodeproj.mk build
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

.PHONY: build
build: package

include $(THEOS)/makefiles/common.mk

XCODEPROJ_NAME = Shook

Shook_XCODE_WORKSPACE = .swiftpm/xcode/package.xcworkspace
Shook_XCODE_SCHEME = Shook

Shook_XCODEFLAGS = BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
Shook_XCODEFLAGS += DEPLOYMENT_LOCATION=YES
Shook_XCODEFLAGS += INSTALL_PATH=/Library/Frameworks
Shook_XCODEFLAGS += DSTROOT=$(THEOS_OBJ_DIR)/install_Shook
#Shook_XCODEFLAGS += IPHONEOS_DEPLOYMENT_TARGET=14.0
#Shook_XCODEFLAGS += SDKROOT=$(THEOS)/sdks/iPhoneOS16.5.sdk
Shook_XCODEFLAGS += -derivedDataPath $(THEOS_OBJ_DIR)/DerivedData
Shook_XCODEFLAGS += DWARF_DSYM_FOLDER_PATH=$(THEOS_OBJ_DIR)/dSYMs
Shook_XCODEFLAGS += CONFIGURATION_BUILD_DIR=$(THEOS_OBJ_DIR)/

include $(THEOS_MAKE_PATH)/xcodeproj.mk

# ── Post-build: stage swiftmodule + plugin, install to theos ──
internal-stage::
	@echo "==> Staging Shook extras..."
	@FMWK=$(THEOS_STAGING_DIR)/Library/Frameworks/Shook.framework; \
	mkdir -p "$$FMWK/Modules"; \
	cp -R $(THEOS_OBJ_DIR)/Shook.swiftmodule "$$FMWK/Modules/"; \
	mkdir -p "$$FMWK/Plugins"; \
	cp $(THEOS_OBJ_DIR)/ShookMacros "$$FMWK/Plugins/"; \
	rm -rf /Users/noah/theos/lib/Shook.framework /Users/noah/theos/lib/iphone/rootless/Shook.framework; \
	cp -R "$$FMWK" /Users/noah/theos/lib/; \
	cp -R "$$FMWK" /Users/noah/theos/lib/iphone/rootless/; \
	echo "   Installed to theos libs"
