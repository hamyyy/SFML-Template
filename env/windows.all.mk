CC := i686-w64-mingw32-g++.exe
CFLAGS := -Wfatal-errors -Wunreachable-code -Wextra -Wall -std=c++17
RC := windres.exe

LIB_DIRS := \
	C:/SFML-2.5.1/lib

INCLUDE_DIRS := \
	C:/SFML-2.5.1/include

BUILD_DEPENDENCIES := \
	C:/SFML-2.5.1/bin/openal32.dll

PRODUCTION_DEPENDENCIES := \
	$(PRODUCTION_DEPENDENCIES) \
	C:/mingw32/bin/libgcc_s_dw2-1.dll \
	C:/mingw32/bin/libstdc++-6.dll \
	C:/mingw32/bin/libwinpthread-1.dll \
	C:/SFML-2.5.1/bin/openal32.dll \
	C:/SFML-2.5.1/bin/sfml-audio-2.dll \
	C:/SFML-2.5.1/bin/sfml-graphics-2.dll \
	C:/SFML-2.5.1/bin/sfml-network-2.dll \
	C:/SFML-2.5.1/bin/sfml-system-2.dll \
	C:/SFML-2.5.1/bin/sfml-window-2.dll
