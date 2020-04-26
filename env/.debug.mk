CFLAGS := -g $(CFLAGS) -pg

LINK_LIBRARIES := \
	sfml-graphics-d \
	sfml-audio-d \
	sfml-network-d \
	sfml-window-d \
	sfml-system-d

BUILD_FLAGS := \
	-pg

BUILD_MACROS := \
	_DEBUG