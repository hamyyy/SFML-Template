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
	/Library/Frameworks/sfml-audio.framework \
	/Library/Frameworks/sfml-graphics.framework \
	/Library/Frameworks/sfml-network.framework \
	/Library/Frameworks/sfml-system.framework \
	/Library/Frameworks/sfml-window.framework \
	/Library/Frameworks/FLAC.framework \
	/Library/Frameworks/ogg.framework \
	/Library/Frameworks/vorbis.framework \
	/Library/Frameworks/vorbisenc.framework \
	/Library/Frameworks/vorbisfile.framework \
	/Library/Frameworks/OpenAL.framework \
	/Library/Frameworks/freetype.framework