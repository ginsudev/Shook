TARGET := iphone:clang:latest:14.0
@@KILL_RULE@@

# Enable the Shook macro module. Must be set before common.mk.
MODULES = shook

include @@THEOS@@/makefiles/common.mk

TWEAK_NAME = @@PROJECTNAME@@

@@PROJECTNAME@@_FILES = $(shell find Sources/@@PROJECTNAME@@ -name '*.swift')
@@PROJECTNAME@@_FILES += $(shell find Sources/@@PROJECTNAME@@C -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
@@PROJECTNAME@@_FILES += $(shell find Sources/@@PROJECTNAME@@Loader -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')

@@PROJECTNAME@@_SWIFTFLAGS = -ISources/@@PROJECTNAME@@C/include
@@PROJECTNAME@@_CFLAGS = -fobjc-arc -ISources/@@PROJECTNAME@@C/include -ISources/@@PROJECTNAME@@Loader/include

include $(THEOS_MAKE_PATH)/tweak.mk
