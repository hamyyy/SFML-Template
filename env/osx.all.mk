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
	$(PRODUCTION_DEPENDENCIES) \
	sfml-audio.framework \
	sfml-graphics.framework \
	sfml-network.framework \
	sfml-system.framework \
	sfml-window.framework \
	FLAC.framework \
	ogg.framework \
	vorbis.framework \
	vorbisenc.framework \
	vorbisfile.framework \
	OpenAL.framework \
	freetype.framework