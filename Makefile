# Makefile primarily supports just "Release" & "Debug" BUILD names right now, but additional ones can be passed as an argument from tasks.json
PLATFORM?=linux
BUILD?=Release
_BUILDL=$(shell echo $(BUILD) | tr A-Z a-z)

include env.mk
-include env/.$(_BUILDL).mk
-include env/$(PLATFORM).all.mk
-include env/$(PLATFORM).$(_BUILDL).mk

#==============================================================================
# File/Folder dependencies for the production build recipe (buildprod)
PRODUCTION_DEPENDENCIES?=
# Extensions to exclude from production builds
PRODUCTION_EXCLUDE?=

#==============================================================================
# Project .cpp or .rc files (relative to src directory)
SOURCE_FILES?=Main.cpp
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
# In case you want to try an alternate version of SFML, the directory can be passed as an argument from tasks.json as well
SFML_DIR?=/usr/local
BUILD_FLAGS?=
BUILD_MACROS?=

# SFML-related
_LIB_DIRS:=$(patsubst %,-L%,$(LIB_DIRS))
_INCLUDE_DIRS:=$(patsubst %,-I%,$(INCLUDE_DIRS))

_BUILD_MACROS:=$(patsubst %,-D%,$(BUILD_MACROS))
_LINK_LIBRARIES:=$(patsubst %,-l%,$(LINK_LIBRARIES))

# Compiler & flags
CC?=g++
RC?=windres.exe
CFLAGS?=-Wfatal-errors -Wextra -Wall -fdiagnostics-color=never

# Scripts
ODIR:=src/obj/$(BUILD)
_RESS:=$(SOURCE_FILES:.rc=.res)
_OBJS:=$(_RESS:.cpp=.o)
OBJS:=$(patsubst %,$(ODIR)/%,$(_OBJS))
SUBDIRS:=$(patsubst %,$(ODIR)/%,$(PROJECT_DIRS))

DEPDIR:=src/dep/$(BUILD)
DEPSUBDIRS:=$(patsubst %,$(DEPDIR)/%,$(PROJECT_DIRS))
_DEPS:=$(SOURCE_FILES:.cpp=.d)
DEPS:=$(patsubst %,$(DEPDIR)/%,$(_DEPS))
$(shell mkdir -p $(DEPDIR) >/dev/null)
DEPFLAGS=-MT $@ -MMD -MP -MF $(DEPDIR)/$*.Td
POSTCOMPILE=@mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d && touch $@

all: makebuild

rebuild: clean makebuild

buildprod: makebuild copyprod

$(ODIR)/%.o: src/%.cpp
$(ODIR)/%.o: src/%.cpp $(DEPDIR)/%.d | $(ODIR) $(SUBDIRS) $(DEPDIR) $(DEPSUBDIRS)
	$(CC) $(DEPFLAGS) $(_BUILD_MACROS) -g $(CFLAGS) $(_INCLUDE_DIRS) -o $@ -c $<
	$(POSTCOMPILE)

$(ODIR)/%.o: src/%.c
$(ODIR)/%.o: src/%.c $(DEPDIR)/%.d | $(ODIR) $(SUBDIRS) $(DEPDIR) $(DEPSUBDIRS)
	$(CC) $(DEPFLAGS) $(_BUILD_MACROS) -g $(CFLAGS) $(_INCLUDE_DIRS) -o $@ -c $<
	$(POSTCOMPILE)

$(ODIR)/%.res: src/%.rc
$(ODIR)/%.res: src/%.rc src/%.h | $(ODIR) $(SUBDIRS) $(DEPDIR) $(DEPSUBDIRS)
	$(RC) -J rc -O coff -i $< -o $@

makebuild: $(OBJS) | bin/$(BUILD)
	$(CC) $(_LIB_DIRS) -o bin/$(BUILD)/$(NAME) $(OBJS) $(_LINK_LIBRARIES) $(BUILD_FLAGS)

$(ODIR) $(SUBDIRS) $(DEPDIR) $(DEPSUBDIRS):
	mkdir -p $@

bin/$(BUILD):
	mkdir -p $@

.PHONY: clean
clean:
	$(RM) $(DEPS)
	$(RM) $(OBJS)

build:
	mkdir -p build

copyprod: bin/$(BUILD) build
	cp $</* build
	$(foreach dir,$(PRODUCTION_DEPENDENCIES),$(shell cp -r $(dir) build))
	$(foreach excl,$(PRODUCTION_EXCLUDE),$(shell find build -name '$(excl)' -delete))

$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

include $(wildcard $(DEPS))