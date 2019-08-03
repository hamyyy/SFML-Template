CC := g++
CFLAGS := $(_CFLAGS_STD) $(_CFLAGS_WARNINGS) -flto -fdiagnostics-color=always

LIB_DIRS := \
	/usr/local/lib

INCLUDE_DIRS := \
	/usr/local/include

BUILD_DEPENDENCIES :=

LINK_LIBRARIES := \
	$(LINK_LIBRARIES) \
	X11

LINUX_ICON := sfml

PRODUCTION_LINUX_APP_NAME := SFML Boilerplate
PRODUCTION_LINUX_APP_COMMENT := My SFML Game
