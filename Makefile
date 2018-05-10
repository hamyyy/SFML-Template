#==============================================================================
# Project .cpp or .rc files (relative to src directory)
_SRCS?=
# Subdirectories within src/ that contain source files
_SUBDIRS?=
# Library directories (separated by spaces)
_LIB?=
_INC?=
# Link libraries (separated by spaces)
_LLS?=

# NAME should always be passed as an argument from tasks.json as the root folder name, but uses a fallback of "game.exe"
# This is used for the output filename (game.exe)
NAME?=game.exe
# Makefile primarily supports just "Release" & "Debug" BUILD names right now, but additional ones can be passed as an argument from tasks.json
BUILD?=Release
# In case you want to try an alternate version of SFML, the directory can be passed as an argument from tasks.json as well
SFMLDIR?=/usr/local
FLAGS_REL?=
FLAGS_DEB?=

_LIB_PRE=$(patsubst %,-L%,$(_LIB))
_INC_PRE=$(patsubst %,-I%,$(_INC))
_LLS_PRE=$(patsubst %,-l%,$(_LLS))

# SFML-related
LIB=-L$(SFMLDIR)/lib $(_LIB_PRE)
INC=-I$(SFMLDIR)/include $(_INC_PRE)
LIB_REL=-lsfml-graphics -lsfml-audio -lsfml-network -lsfml-window -lsfml-system $(_LLS_PRE) $(FLAGS_REL)
LIB_DEB=-lsfml-graphics-d -lsfml-audio-d -lsfml-network-d -lsfml-window-d -lsfml-system-d $(_LLS_PRE) $(FLAGS_DEB)

# Compiler & flags
CC?=g++
RC?=windres.exe
CFLAGS?=-Os -Wfatal-errors -Wextra -Wall -std=c++14 -fdiagnostics-color=never

# Scripts
ODIR=src/obj/$(BUILD)
_RESS=$(_SRCS:.rc=.res)
_OBJS=$(_RESS:.cpp=.o)
OBJS=$(patsubst %,$(ODIR)/%,$(_OBJS))
SUBDIRS=$(patsubst %,$(ODIR)/%,$(_SUBDIRS))

DEPDIR=src/dep/$(BUILD)
DEPSUBDIRS=$(patsubst %,$(DEPDIR)/%,$(_SUBDIRS))
_DEPS=$(_SRCS:.cpp=.d)
DEPS=$(patsubst %,$(DEPDIR)/%,$(_DEPS))
$(shell mkdir -p $(DEPDIR) >/dev/null)
DEPFLAGS = -MT $@ -MMD -MP -MF $(DEPDIR)/$*.Td
POSTCOMPILE = @mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d && touch $@

all: build

rebuild: clean build

$(ODIR)/%.o: src/%.cpp
$(ODIR)/%.o: src/%.cpp $(DEPDIR)/%.d | $(ODIR) $(SUBDIRS) $(DEPDIR) $(DEPSUBDIRS)
	$(CC) $(DEPFLAGS) -g $(CFLAGS) $(INC) -o $@ -c $<
	$(POSTCOMPILE)

$(ODIR)/%.o: src/%.c
$(ODIR)/%.o: src/%.c $(DEPDIR)/%.d | $(ODIR) $(SUBDIRS) $(DEPDIR) $(DEPSUBDIRS)
	$(CC) $(DEPFLAGS) -g $(CFLAGS) $(INC) -o $@ -c $<
	$(POSTCOMPILE)

$(ODIR)/%.res: src/%.rc
$(ODIR)/%.res: src/%.rc src/%.h | $(ODIR) $(SUBDIRS) $(DEPDIR) $(DEPSUBDIRS)
	$(RC) -J rc -O coff -i $< -o $@

build: $(OBJS) | bin/$(BUILD)
ifeq ($(BUILD),Release)
	$(CC) $(LIB) -o bin/$(BUILD)/$(NAME) $(OBJS) $(LIB_REL)
else
	$(CC) $(LIB) -o bin/$(BUILD)/$(NAME) $(OBJS) $(LIB_DEB)
endif

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