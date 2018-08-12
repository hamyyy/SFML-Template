#==============================================================================
# Project .cpp or .rc files (relative to src directory)
SOURCE_FILES?=
# Project subdirectories within src/ that contain source files
PROJECT_DIRS?=
# Library directories (separated by spaces)
LIB_DIRS?=
INCLUDE_DIRS?=
# Link libraries (separated by spaces)
LINK_LIBRARIES?=

# NAME should always be passed as an argument from tasks.json as the root folder name, but uses a fallback of "game.exe"
# This is used for the output filename (game.exe)
NAME?=game.exe
# Makefile primarily supports just "Release" & "Debug" BUILD names right now, but additional ones can be passed as an argument from tasks.json
BUILD?=Release
# In case you want to try an alternate version of SFML, the directory can be passed as an argument from tasks.json as well
SFML_DIR?=/usr/local
FLAGS_RELEASE?=
FLAGS_DEBUG?=

MACROS_RELEASE?=
MACROS_DEBUG?=_DEBUG

_LIB_PRE=$(patsubst %,-L%,$(LIB_DIRS))
_INC_PRE=$(patsubst %,-I%,$(INCLUDE_DIRS))
_LLS_PRE=$(patsubst %,-l%,$(LINK_LIBRARIES))

# SFML-related
LIB=-L$(SFML_DIR)/lib $(_LIB_PRE)
INC=-I$(SFML_DIR)/include $(_INC_PRE)

# Debug/Release conditions
ifeq ($(BUILD),Release)
_MACROS=$(patsubst %,-D%,$(MACROS_RELEASE))
_LIBS=-lsfml-graphics -lsfml-audio -lsfml-network -lsfml-window -lsfml-system $(_LLS_PRE) $(FLAGS_RELEASE)
else
_MACROS=$(patsubst %,-D%,$(MACROS_DEBUG))
_LIBS=-lsfml-graphics-d -lsfml-audio-d -lsfml-network-d -lsfml-window-d -lsfml-system-d $(_LLS_PRE) $(FLAGS_DEBUG)
endif

# Compiler & flags
CC?=g++
RC?=windres.exe
CFLAGS?=-Os -Wfatal-errors -Wextra -Wall -std=c++14 -fdiagnostics-color=never

# Scripts
ODIR=src/obj/$(BUILD)
_RESS=$(SOURCE_FILES:.rc=.res)
_OBJS=$(_RESS:.cpp=.o)
OBJS=$(patsubst %,$(ODIR)/%,$(_OBJS))
SUBDIRS=$(patsubst %,$(ODIR)/%,$(PROJECT_DIRS))

DEPDIR=src/dep/$(BUILD)
DEPSUBDIRS=$(patsubst %,$(DEPDIR)/%,$(PROJECT_DIRS))
_DEPS=$(SOURCE_FILES:.cpp=.d)
DEPS=$(patsubst %,$(DEPDIR)/%,$(_DEPS))
$(shell mkdir -p $(DEPDIR) >/dev/null)
DEPFLAGS = -MT $@ -MMD -MP -MF $(DEPDIR)/$*.Td
POSTCOMPILE = @mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d && touch $@

all: build

rebuild: clean build

$(ODIR)/%.o: src/%.cpp
$(ODIR)/%.o: src/%.cpp $(DEPDIR)/%.d | $(ODIR) $(SUBDIRS) $(DEPDIR) $(DEPSUBDIRS)
	$(CC) $(DEPFLAGS) $(_MACROS) -g $(CFLAGS) $(INC) -o $@ -c $<
	$(POSTCOMPILE)

$(ODIR)/%.o: src/%.c
$(ODIR)/%.o: src/%.c $(DEPDIR)/%.d | $(ODIR) $(SUBDIRS) $(DEPDIR) $(DEPSUBDIRS)
	$(CC) $(DEPFLAGS) $(_MACROS) -g $(CFLAGS) $(INC) -o $@ -c $<
	$(POSTCOMPILE)

$(ODIR)/%.res: src/%.rc
$(ODIR)/%.res: src/%.rc src/%.h | $(ODIR) $(SUBDIRS) $(DEPDIR) $(DEPSUBDIRS)
	$(RC) -J rc -O coff -i $< -o $@

build: $(OBJS) | bin/$(BUILD)
	$(CC) $(LIB) -o bin/$(BUILD)/$(NAME) $(OBJS) $(_LIBS)

$(ODIR) $(SUBDIRS) $(DEPDIR) $(DEPSUBDIRS):
	mkdir -p $@

bin/$(BUILD):
	mkdir -p $@

.PHONY: clean
clean:
	$(RM) $(DEPS)
	$(RM) $(OBJS)

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

include $(wildcard $(DEPS))