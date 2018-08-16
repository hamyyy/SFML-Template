CC=g++
CFLAGS_ALL=-Wfatal-errors -Wextra -Wall -fdiagnostics-color=never

LIB_DIRS= \
	/usr/local/lib

INCLUDE_DIRS= \
	/usr/local/include

BUILD_DEPENDENCIES=

PRODUCTION_DEPENDENCIES= \
	content

PRODUCTION_EXCLUDE= \
	*.psd \
	*.rar \
	*.7z \
	Thumbs.db