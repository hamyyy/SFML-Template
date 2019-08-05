CC := clang++
CFLAGS := $(CFLAGS:-s=)

LIB_DIRS := \
	/usr/local/lib

INCLUDE_DIRS := \
	/usr/local/include

BUILD_DEPENDENCIES :=

MACOS_ICON := sfml

BUILD_FLAGS := \
	-F/Library/Frameworks \
	-framework CoreFoundation

PRODUCTION_DEPENDENCIES := \
	$(PRODUCTION_DEPENDENCIES)

PRODUCTION_MACOS_BUNDLE_DEVELOPER := developer
PRODUCTION_MACOS_BUNDLE_DISPLAY_NAME := SFML Boilerplate
PRODUCTION_MACOS_BUNDLE_NAME := SFML Boilerplate
PRODUCTION_MACOS_MAKE_DMG := true
PRODUCTION_MACOS_BACKGROUND := dmg-background

PRODUCTION_MACOS_DYLIBS := \
	/usr/local/lib/libsfml-graphics.2.5 \
	/usr/local/lib/libsfml-audio.2.5 \
	/usr/local/lib/libsfml-network.2.5 \
	/usr/local/lib/libsfml-window.2.5 \
	/usr/local/lib/libsfml-system.2.5

PRODUCTION_MACOS_FRAMEWORKS :=
