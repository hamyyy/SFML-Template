CFLAGS=-g $(CFLAGS_ALL) -pg

BUILD_FLAGS= \
	-pg

BUILD_MACROS= \
	_DEBUG

LINK_LIBRARIES= \
	sfml-graphics \
	sfml-audio \
	sfml-network \
	sfml-window \
	sfml-system