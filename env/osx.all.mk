CC := clang++
CFLAGS := -Wfatal-errors -Wunreachable-code -Wextra -Wall -std=c++17
DUMP_ASSEMBLY := false

LIB_DIRS := \
	/usr/local/lib

INCLUDE_DIRS := \
	/usr/local/include

BUILD_DEPENDENCIES :=

MACOS_ICON := sfml

BUILD_FLAGS := \
	-framework CoreFoundation

PRODUCTION_DEPENDENCIES := \
	$(PRODUCTION_DEPENDENCIES)

PRODUCTION_MACOS_BUNDLE_DEVELOPER := developer
PRODUCTION_MACOS_BUNDLE_DISPLAY_NAME := SFML Boilerplate
PRODUCTION_MACOS_BUNDLE_NAME := SFMLBoilerplate

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
