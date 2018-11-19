CC := clang++
CFLAGS := -Wfatal-errors -Wunreachable-code -Wextra -Wall -std=c++17

LIB_DIRS := \
	/usr/local/lib

INCLUDE_DIRS := \
	/usr/local/include

BUILD_DEPENDENCIES :=

MACOS_ICON := sfml

PRODUCTION_DEPENDENCIES := \
	$(PRODUCTION_DEPENDENCIES)