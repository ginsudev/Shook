# Shook — compile-time Swift macro framework for Objective-C method hooking.
# Enable with `MODULES = shook` (per project) or `THEOS_AUTOLOAD_MODULES = shook` (global).

_THEOS_SHOOK_PATH   ?= $(THEOS_MODULE_PATH)/shook
_THEOS_SHOOK_PLUGIN ?= $(_THEOS_SHOOK_PATH)/.theos_build/release/ShookMacros
_THEOS_SHOOK_MODULES := $(_THEOS_SHOOK_PATH)/.theos_build/Shook.framework/Modules

# Inject the macro plugin flag + module search path for any Swift target.
ifneq ($(_SWIFT_FILE_COUNT),0)
_THEOS_INTERNAL_SWIFTFLAGS += -F$(_THEOS_SHOOK_PATH)/.theos_build -load-plugin-executable $(_THEOS_SHOOK_PLUGIN)\#ShookMacros
endif

.PHONY: internal-$(THEOS_CURRENT_INSTANCE)-shook

before-$(THEOS_CURRENT_INSTANCE)-all::
	$(ECHO_NOTHING)if mkdir $(_THEOS_SWIFT_MARKERS_DIR)/shook 2>/dev/null; then \
		$(MAKE) -f $(_THEOS_PROJECT_MAKEFILE_NAME) $(_THEOS_MAKEFLAGS) internal-$(THEOS_CURRENT_INSTANCE)-shook THEOS_BUILD_SHOOK=$(_THEOS_TRUE) || exit $$?; \
	else :; \
	fi$(ECHO_END)

ifeq ($(THEOS_BUILD_SHOOK),$(_THEOS_TRUE))
internal-$(THEOS_CURRENT_INSTANCE)-shook::
	$(ECHO_NOTHING)$(THEOS_BIN_PATH)/swift-bootstrapper.pl $(_THEOS_PLATFORM_SWIFT) $(_THEOS_SHOOK_PATH) '$(PRINT_FORMAT_BLUE) "Building Shook macro plugin (this may take a while)"' >&2$(ECHO_END)
	$(ECHO_NOTHING)mkdir -p $(_THEOS_SHOOK_MODULES)/Shook.swiftmodule$(ECHO_END)
	$(ECHO_NOTHING)$(TARGET_SWIFTC) -emit-module -module-name Shook -target arm64-$(_THEOS_TARGET_SWIFT_TARGET) $(_THEOS_TARGET_SWIFTFLAGS) -parse-as-library -load-plugin-executable $(_THEOS_SHOOK_PLUGIN)\#ShookMacros $(_THEOS_SHOOK_PATH)/Sources/Shook/Shook.swift -emit-module-path $(_THEOS_SHOOK_MODULES)/Shook.swiftmodule/arm64-apple-ios.swiftmodule$(ECHO_END)
	$(ECHO_NOTHING)cp $(_THEOS_SHOOK_MODULES)/Shook.swiftmodule/arm64-apple-ios.swiftmodule $(_THEOS_SHOOK_MODULES)/Shook.swiftmodule/arm64e-apple-ios.swiftmodule$(ECHO_END)
	$(ECHO_NOTHING)cp $(_THEOS_SHOOK_MODULES)/Shook.swiftmodule/arm64-apple-ios.swiftdoc $(_THEOS_SHOOK_MODULES)/Shook.swiftmodule/arm64e-apple-ios.swiftdoc$(ECHO_END)

ifeq ($(_THEOS_INTERNAL_USE_PARALLEL_BUILDING),$(_THEOS_TRUE))
MAKEFLAGS += -Onone
endif
endif
