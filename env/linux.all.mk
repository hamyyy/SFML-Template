CC := g++

LIB_DIRS := \
	/usr/local/lib

INCLUDE_DIRS := \
	/usr/local/include

BUILD_DEPENDENCIES :=

BUILD_FLAGS := \
	$(BUILD_FLAGS) \
	-pthread

LINK_LIBRARIES := \
	$(LINK_LIBRARIES) \
	X11

LINUX_ICON := sfml

PRODUCTION_LINUX_APP_NAME := SFML Boilerplate
PRODUCTION_LINUX_APP_COMMENT := My SFML Game
