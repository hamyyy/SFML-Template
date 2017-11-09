#==============================================================================
# Project .cpp or .rc files (relative to src directory)
_SRCS=Main.cpp
# Subdirectories within src\ that contain source files
_SUBDIRS=
# Link libraries (prefixed with -l)
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
RC=windres.exe
CFLAGS=-fexpensive-optimizations -Os -Wfatal-errors -Wextra -Wall -std=c++14

# Scripts
ODIR=src\obj\$(BUILD)
_RESS=$(_SRCS:.rc=.res)
_OBJS=$(_RESS:.cpp=.o)
OBJS=$(patsubst %,$(ODIR)\\%,$(_OBJS))
SUBDIRS=$(patsubst %,$(ODIR)\\%,$(_SUBDIRS))

all: build

rebuild: clean build

$(ODIR)\\%.o: src\%.cpp | $(ODIR) $(SUBDIRS)
	$(CC) -g $(CFLAGS) -I$(INC) -o $@ -c $<

$(ODIR)\\%.res: src\%.rc | $(ODIR) $(SUBDIRS)
	$(RC) -J rc -O coff -i $< -o $@

build: $(OBJS) | bin\$(BUILD)
ifeq ($(BUILD),Release)
	$(CC) -L$(SFMLLIB) -o bin\$(BUILD)\$(NAME).exe $(OBJS) $(LIB_REL)
else
	$(CC) -L$(SFMLLIB) -o bin\$(BUILD)\$(NAME).exe $(OBJS) $(LIB_DEB)
endif

$(ODIR) $(SUBDIRS):
	mkdir $@

bin\$(BUILD):
	mkdir $@

.PHONY: clean
clean:
	if exist $(ODIR) del $(ODIR) /F /Q