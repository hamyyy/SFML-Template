#==============================================================================
# Add project cpp files here (relative to src directory)
_SRCS=Main.cpp
# Add additional link libraries here (prefixed with -l)
_LLS=

#==============================================================================
# NAME should always be passed as an argument from tasks.json as the root folder name, but uses a fallback of "game"
# This is used for the output filename (game.exe)
NAME?=game
# Makefile primarily supports just "Release" & "Debug" BUILD names right now, but additional ones can be passed as an argument from tasks.json
BUILD?=Release
# In case you want to try an older version of SFML (not recommended), the directory can be passed as an argument from tasks.json as well
SFMLDIR?=C:\SFML-2.4.2

# SFML-related
INC=$(SFMLDIR)\include
SFMLLIB=$(SFMLDIR)\lib
LIB_REL=-lsfml-graphics -lsfml-audio -lsfml-network -lsfml-window -lsfml-system $(_LLS) -mwindows
LIB_DEB=-lsfml-graphics-d -lsfml-audio-d -lsfml-network-d -lsfml-window-d -lsfml-system-d $(_LLS)

# Compiler & flags
CC=i686-w64-mingw32-g++.exe
CFLAGS=-fexpensive-optimizations -Os -Wfatal-errors -Wextra -Wall -std=c++14

# Scripts
ODIR=obj\$(BUILD)
_OBJS=$(_SRCS:.cpp=.o)
OBJS=$(patsubst %,src\$(ODIR)\\%,$(_OBJS))

all: build

rebuild: clean build

src\$(ODIR)\\%.o: src\\%.cpp | src\$(ODIR)
	$(CC) -g $(CFLAGS) -I$(INC) -o $@ -c $<

build: $(OBJS) | bin\$(BUILD)
ifeq ($(BUILD),Release)
	$(CC) -L$(SFMLLIB) -o bin\$(BUILD)\$(NAME).exe $(OBJS) $(LIB_REL)
else
	$(CC) -L$(SFMLLIB) -o bin\$(BUILD)\$(NAME).exe $(OBJS) $(LIB_DEB)
endif

src\obj\$(BUILD):
	mkdir src\obj\$(BUILD)

bin\$(BUILD):
	mkdir bin\$(BUILD)

.PHONY: clean
clean:
	del $(OBJS)