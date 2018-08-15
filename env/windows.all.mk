CC=i686-w64-mingw32-g++.exe
CFLAGS=-Os -Wfatal-errors -Wunreachable-code -Wextra -Wall -std=c++17 -fdiagnostics-color=never
RC=windres.exe

LIB_DIRS= \
	C:/SFML-2.5.0/lib

INCLUDE_DIRS= \
	C:/SFML-2.5.0/include

PRODUCTION_DEPENDENCIES= \
	C:/mingw32/bin/libgcc_s_dw2-1.dll \
	C:/mingw32/bin/libstdc++-6.dll \
	C:/mingw32/bin/libwinpthread-1.dll \
	content

PRODUCTION_EXCLUDE= \
	*.psd \
	*.rar \
	*.7z \
	Thumbs.db