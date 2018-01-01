#==============================================================================
# Project .cpp or .rc files (relative to src directory)
_SRCS=Main.cpp
# Subdirectories within src\ that contain source files
_SUBDIRS=

# Library directories (separated by spaces)
_LIB=
_INC=
# Link libraries (prefixed with -l)
_LLS=

#==============================================================================
# NAME should always be passed as an argument from tasks.json as the root folder name, but uses a fallback of "game"
# This is used for the output filename (game.exe)
NAME?=game
# Makefile primarily supports just "Release" & "Debug" BUILD names right now, but additional ones can be passed as an argument from tasks.json
BUILD?=Release
# In case you want to try an alternate version of SFML, the directory can be passed as an argument from tasks.json as well
SFMLDIR?=C:\SFML-2.4.2

_LIB_PRE=$(patsubst %,-L%,$(_LIB))
_INC_PRE=$(patsubst %,-I%,$(_INC))
_LLS_PRE=$(patsubst %,-l%,$(_LLS))

# SFML-related
LIB=-L$(SFMLDIR)\lib $(_LIB_PRE)
INC=-I$(SFMLDIR)\include $(_INC_PRE)
LIB_REL=-lsfml-graphics -lsfml-audio -lsfml-network -lsfml-window -lsfml-system $(_LLS_PRE) -mwindows
LIB_DEB=-lsfml-graphics-d -lsfml-audio-d -lsfml-network-d -lsfml-window-d -lsfml-system-d $(_LLS_PRE)

# Compiler & flags
CC=i686-w64-mingw32-g++.exe
RC=windres.exe
CFLAGS=-Os -Wfatal-errors -Wextra -Wall -std=c++14

# Scripts
ODIR=src\obj\$(BUILD)
_RESS=$(_SRCS:.rc=.res)
_OBJS=$(_RESS:.cpp=.o)
OBJS=$(patsubst %,$(ODIR)\\%,$(_OBJS))
SUBDIRS=$(patsubst %,$(ODIR)\\%,$(_SUBDIRS))

all: build

rebuild: clean build

$(ODIR)\\%.o: src\%.cpp src\%.hpp | $(ODIR) $(SUBDIRS)
	$(CC) -g $(CFLAGS) $(INC) -o $@ -c $<

$(ODIR)\\%.o: src\%.cpp src\%.h | $(ODIR) $(SUBDIRS)
	$(CC) -g $(CFLAGS) $(INC) -o $@ -c $<

$(ODIR)\\%.o: src\%.c src\%.h | $(ODIR) $(SUBDIRS)
	$(CC) -g $(CFLAGS) $(INC) -o $@ -c $<

$(ODIR)\\%.res: src\%.rc src\%.h | $(ODIR) $(SUBDIRS)
	$(RC) -J rc -O coff -i $< -o $@

build: $(OBJS) | bin\$(BUILD)
ifeq ($(BUILD),Release)
	$(CC) $(LIB) -o bin\$(BUILD)\$(NAME).exe $(OBJS) $(LIB_REL)
else
	$(CC) $(LIB) -o bin\$(BUILD)\$(NAME).exe $(OBJS) $(LIB_DEB)
endif

$(ODIR) $(SUBDIRS):
	mkdir $@

bin\$(BUILD):
	mkdir $@

.PHONY: clean
clean:
	if exist $(ODIR) del $(ODIR) /F /Q