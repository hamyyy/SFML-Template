CC := clang++
CFLAGS := $(CFLAGS:-s=)

LIB_DIRS := \
	/usr/local/lib

INCLUDE_DIRS := \
	/usr/local/include

BUILD_DEPENDENCIES :=

MACOS_ICON := sfml

LINK_LIBRARIES :=

BUILD_FLAGS := \
	-F/Library/Frameworks \
	-framework sfml-audio \
	-framework sfml-graphics \
	-framework sfml-network \
	-framework sfml-system \
	-framework sfml-window \
	-framework CoreFoundation

PRODUCTION_DEPENDENCIES := \
	$(PRODUCTION_DEPENDENCIES)

PRODUCTION_MACOS_BUNDLE_DEVELOPER := developer
PRODUCTION_MACOS_BUNDLE_DISPLAY_NAME := SFML Boilerplate
PRODUCTION_MACOS_BUNDLE_NAME := SFML Boilerplate
PRODUCTION_MACOS_MAKE_DMG := true
PRODUCTION_MACOS_BACKGROUND := dmg-background

PRODUCTION_MACOS_FRAMEWORKS := \
	sfml-audio \
	sfml-graphics \
	sfml-network \
	sfml-system \
	sfml-window \
	FLAC \
	ogg \
	vorbis \
	vorbisenc \
	vorbisfile \
	OpenAL \
	freetype
