#==============================================================================
# Build platform
PLATFORM?=linux
# Build description (Primarily uses Debug/Release)
BUILD?=Release
_BUILDL := $(shell echo $(BUILD) | tr A-Z a-z)

# Platform specific environment variables
-include env/.all.mk
-include env/.$(_BUILDL).mk
-include env/$(PLATFORM).all.mk
-include env/$(PLATFORM).$(_BUILDL).mk

#==============================================================================
# File/Folder dependencies for the production build recipe (makeproduction)
PRODUCTION_DEPENDENCIES?=
# Extensions to exclude from production builds
PRODUCTION_EXCLUDE?=
# Folder location (relative or absolute) to place the production build into
PRODUCTION_FOLDER?=build

#==============================================================================
# Library directories (separated by spaces)
LIB_DIRS?=
INCLUDE_DIRS?=
# Link libraries (separated by spaces)
LINK_LIBRARIES?=

# Build-specific preprocessor macros
BUILD_MACROS?=
# Build-specific compiler flags to be appended to the final build step (with prefix)
BUILD_FLAGS?=

# Build dependencies to copy into the bin/(build) folder - example: openal32.dll
BUILD_DEPENDENCIES?=

# NAME should always be passed as an argument from tasks.json as the root folder name, but uses a fallback of "game.exe"
# This is used for the output filename (game.exe)
NAME?=game.exe

#==============================================================================
# Project .cpp or .rc files (relative to src directory)
SOURCE_FILES := $(patsubst src/%,%,$(shell find src -name '*.cpp' -o -name '*.c' -o -name '*.rc'))
# Project subdirectories within src/ that contain source files
PROJECT_DIRS := $(patsubst src/%,%,$(shell find src -mindepth 1 -maxdepth 99 -type d))

# Add prefixes to the above variables
_LIB_DIRS := $(patsubst %,-L%,$(LIB_DIRS))
_INCLUDE_DIRS := $(patsubst %,-I%,$(INCLUDE_DIRS))

_BUILD_MACROS := $(patsubst %,-D%,$(BUILD_MACROS))
_LINK_LIBRARIES := $(patsubst %,-l%,$(LINK_LIBRARIES))

#==============================================================================
# Directories & Dependencies
BDIR := bin/$(BUILD)
BDIR := $(patsubst %/,%,$(BDIR))
_EXE := $(BDIR)/$(NAME)
_NAMENOEXT := $(NAME:.exe=)
_NAMENOEXT := $(_NAMENOEXT:.dll=)

ODIR := $(BDIR)/obj
_OBJS := $(SOURCE_FILES:.rc=.res)
_OBJS := $(_OBJS:.c=.o)
_OBJS := $(_OBJS:.cpp=.o)
OBJS := $(patsubst %,$(ODIR)/%,$(_OBJS))
SUBDIRS := $(patsubst %,$(ODIR)/%,$(PROJECT_DIRS))

DEPDIR := $(BDIR)/dep
_DEPS := $(SOURCE_FILES:.rc=.res)
_DEPS := $(_DEPS:.c=.d)
_DEPS := $(_DEPS:.cpp=.d)
DEPS := $(patsubst %,$(DEPDIR)/%,$(_DEPS))
DEPSUBDIRS := $(patsubst %,$(DEPDIR)/%,$(PROJECT_DIRS))

ifeq ($(DUMP_ASSEMBLY),true)
	ASMDIR := $(BDIR)/asm
	_ASMS := $(_OBJS:%.res=)
	_ASMS := $(_ASMS:.o=.o.asm)
	ASMS := $(patsubst %,$(ASMDIR)/%,$(_ASMS))
	ASMSUBDIRS := $(patsubst %,$(ASMDIR)/%,$(PROJECT_DIRS))
endif

_DIRECTORIES := bin $(BDIR) $(ODIR) $(SUBDIRS) $(DEPDIR) $(DEPSUBDIRS) $(ASMDIR) $(ASMSUBDIRS)
_DIRECTORIES := $(sort $(_DIRECTORIES))
_BUILD_DEPENDENCIES := $(patsubst %,$(BDIR)/%,$(notdir $(BUILD_DEPENDENCIES)))

#==============================================================================
# Compiler & flags
CC?=g++
RC?=windres.exe
CFLAGS_ALL?=-Wfatal-errors -Wextra -Wall -fdiagnostics-color=never
CFLAGS?=-g $(CFLAGS_ALL)
CFLAGS_DEPS=-MT $@ -MMD -MP -MF $(DEPDIR)/$*.Td

POST_COMPILE=@mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d && touch $@

#==============================================================================
# Build Scripts
all: makebuild

rebuild: clean makebuild

buildprod: makebuild makeproduction

#==============================================================================
# Build Recipes
$(ODIR)/%.o: src/%.cpp
$(ODIR)/%.o: src/%.cpp $(DEPDIR)/%.d | $(_DIRECTORIES)
	$(CC) $(CFLAGS_DEPS) $(_BUILD_MACROS) $(CFLAGS) $(_INCLUDE_DIRS) -o $@ -c $<
	$(POST_COMPILE)

$(ODIR)/%.o: src/%.c
$(ODIR)/%.o: src/%.c $(DEPDIR)/%.d | $(_DIRECTORIES)
	$(CC) $(CFLAGS_DEPS) $(_BUILD_MACROS) $(CFLAGS) $(_INCLUDE_DIRS) -o $@ -c $<
	$(POST_COMPILE)

$(ODIR)/%.res: src/%.rc
$(ODIR)/%.res: src/%.rc src/%.h | $(_DIRECTORIES)
	$(RC) -J rc -O coff -i $< -o $@

$(ASMDIR)/%.o.asm: $(ODIR)/%.o
	objdump -d -C -Mintel $< > $@

$(BDIR)/%.dll:
	-cp -r $@ $(BDIR)

$(BDIR)/%.so:
	-cp -r $@ $(BDIR)

$(_EXE): $(OBJS) $(ASMS) $(BDIR) $(_BUILD_DEPENDENCIES)
ifeq ($(suffix $(_EXE)),.dll)
	-rm -f $(BDIR)/lib$(_NAMENOEXT).def
	-rm -f $(BDIR)/lib$(_NAMENOEXT).a
	$(CC) -shared -Wl,--output-def="$(BDIR)/lib$(_NAMENOEXT).def" -Wl,--out-implib="$(BDIR)/lib$(_NAMENOEXT).a" -Wl,--dll $(_LIB_DIRS) $(OBJS) -o $@ -s $(_LINK_LIBRARIES) $(BUILD_FLAGS)
else
	$(CC) $(_LIB_DIRS) -o $@ $(OBJS) $(_LINK_LIBRARIES) $(BUILD_FLAGS)
endif

makebuild: $(_EXE)
	@echo '$(BUILD) build target is up to date.'

$(_DIRECTORIES):
	mkdir -p $@

.PHONY: clean
clean:
	$(RM) $(_EXE)
	$(RM) $(DEPS)
	$(RM) $(OBJS)

#==============================================================================
# Production recipes
rmbuild:
	-rm -f -r $(PRODUCTION_FOLDER)

mkdirbuild:
	mkdir -p $(PRODUCTION_FOLDER)

releasetobuild: $(_EXE)
	cp $(_EXE) $(PRODUCTION_FOLDER)

makeproduction: rmbuild mkdirbuild releasetobuild
	@echo -n 'Adding dynamic libraries & project dependencies...'
	$(foreach dep,$(PRODUCTION_DEPENDENCIES),$(shell cp -r $(dep) $(PRODUCTION_FOLDER)))
	$(foreach excl,$(PRODUCTION_EXCLUDE),$(shell find $(PRODUCTION_FOLDER) -name '$(excl)' -delete))
	@echo ' Done'

#==============================================================================
# Dependency recipes
$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d

include $(wildcard $(DEPS))