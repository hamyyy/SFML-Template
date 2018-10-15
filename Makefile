#==============================================================================
# Build platform
PLATFORM?=linux
# Build description (Primarily uses Debug/Release)
BUILD?=Release
_BUILDL := $(shell echo $(BUILD) | tr A-Z a-z)

# Maximum parallel jobs during build process
MAX_PARALLEL_JOBS?=8

# Dump assembly?
DUMP_ASSEMBLY?=false

# Clean output?
CLEAN_OUTPUT?=true

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
_INCLUDE_DIRS := $(patsubst %,-I%,src/ $(INCLUDE_DIRS))

_BUILD_MACROS := $(patsubst %,-D%,$(BUILD_MACROS))
_LINK_LIBRARIES := $(patsubst %,-l%,$(LINK_LIBRARIES))

#==============================================================================
# Directories & Dependencies
BLD_DIR := bin/$(BUILD)
BLD_DIR := $(patsubst %/,%,$(BLD_DIR))
_EXE := $(BLD_DIR)/$(NAME)
_NAMENOEXT := $(NAME:.exe=)
_NAMENOEXT := $(_NAMENOEXT:.dll=)

OBJ_DIR := $(BLD_DIR)/obj
ifeq ($(PLATFORM),windows)
	_OBJS := $(SOURCE_FILES:.rc=.res)
else
	_OBJS := $(SOURCE_FILES:%.rc=)
endif
_OBJS := $(_OBJS:.c=.o)
_OBJS := $(_OBJS:.cpp=.o)
OBJS := $(patsubst %,$(OBJ_DIR)/%,$(_OBJS))
OBJ_SUBDIRS := $(patsubst %,$(OBJ_DIR)/%,$(PROJECT_DIRS))

DEP_DIR := $(BLD_DIR)/dep
ifeq ($(PLATFORM),windows)
	_DEPS := $(SOURCE_FILES:.rc=.res)
else
	_DEPS := $(SOURCE_FILES:%.rc=)
endif
_DEPS := $(_DEPS:.c=.d)
_DEPS := $(_DEPS:.cpp=.d)
DEPS := $(patsubst %,$(DEP_DIR)/%,$(_DEPS))
DEP_SUBDIRS := $(patsubst %,$(DEP_DIR)/%,$(PROJECT_DIRS))

ifeq ($(DUMP_ASSEMBLY),true)
	ASM_DIR := $(BLD_DIR)/asm
	_ASMS := $(_OBJS:%.res=)
	_ASMS := $(_ASMS:.o=.o.asm)
	ASMS := $(patsubst %,$(ASM_DIR)/%,$(_ASMS))
	ASM_SUBDIRS := $(patsubst %,$(ASM_DIR)/%,$(PROJECT_DIRS))
endif

_DIRECTORIES := bin $(BLD_DIR) $(OBJ_DIR) $(OBJ_SUBDIRS) $(DEP_DIR) $(DEP_SUBDIRS) $(ASM_DIR) $(ASM_SUBDIRS)
_DIRECTORIES := $(sort $(_DIRECTORIES))
_BUILD_DEPENDENCIES := $(filter %.dll,$(BUILD_DEPENDENCIES))
_BUILD_DEPENDENCIES := $(patsubst %,$(BLD_DIR)/%,$(notdir $(_BUILD_DEPENDENCIES)))

# Quiet flag
ifeq ($(CLEAN_OUTPUT),true)
	_Q=@
else
	_Q=
endif

#==============================================================================
# Compiler & flags
CC?=g++
RC?=windres.exe
CFLAGS_ALL?=-Wfatal-errors -Wextra -Wall -fdiagnostics-color=never
CFLAGS?=-g $(CFLAGS_ALL)
CFLAGS_DEPS=-MT $@ -MMD -MP -MF $(DEP_DIR)/$*.Td

OBJ_COMPILE = $(CC) $(CFLAGS_DEPS) $(_BUILD_MACROS) $(CFLAGS) $(_INCLUDE_DIRS) -o $@ -c $<
RC_COMPILE = -$(RC) -J rc -O coff -i $< -o $@
ASM_COMPILE = objdump -d -C -Mintel $< > $@
POST_COMPILE = @mv -f $(DEP_DIR)/$*.Td $(DEP_DIR)/$*.d && touch $@

#==============================================================================
# Build Scripts
all:
	@$(MAKE) -j$(MAX_PARALLEL_JOBS) --no-print-directory makebuild

rebuild: clean all

buildprod: all makeproduction

#==============================================================================

# Build Recipes
$(OBJ_DIR)/%.o: src/%.c
$(OBJ_DIR)/%.o: src/%.c $(DEP_DIR)/%.d | $(_DIRECTORIES)
	$(_Q)$(OBJ_COMPILE)
ifeq ($(CLEAN_OUTPUT),true)
	@echo $(patsubst $(OBJ_DIR)/%,%,$<)
endif
	$(POST_COMPILE)

$(OBJ_DIR)/%.o: src/%.cpp
$(OBJ_DIR)/%.o: src/%.cpp $(DEP_DIR)/%.d | $(_DIRECTORIES)
	$(_Q)$(OBJ_COMPILE)
ifeq ($(CLEAN_OUTPUT),true)
	@echo $(patsubst $(OBJ_DIR)/%,%,$<)
endif
	$(POST_COMPILE)

$(OBJ_DIR)/%.res: src/%.rc
$(OBJ_DIR)/%.res: src/%.rc src/%.h | $(_DIRECTORIES)
	$(_Q)$(RC_COMPILE)
ifeq ($(CLEAN_OUTPUT),true)
	@echo $(patsubst $(OBJ_DIR)/%,%,$<)
endif

$(ASM_DIR)/%.o.asm: $(OBJ_DIR)/%.o
	$(_Q)$(ASM_COMPILE)

$(BLD_DIR)/%.dll:
	$(foreach dep,$(BUILD_DEPENDENCIES),$(shell cp -r $(dep) $(BLD_DIR)))

$(BLD_DIR)/%.so:
	$(foreach dep,$(BUILD_DEPENDENCIES),$(shell cp -r $(dep) $(BLD_DIR)))

$(_EXE): $(OBJS) $(ASMS) $(BLD_DIR) $(_BUILD_DEPENDENCIES)
ifeq ($(CLEAN_OUTPUT),true)
	@echo
	@echo 'Linking: $(_EXE)'
endif
ifeq ($(suffix $(_EXE)),.dll)
	-rm -f $(BLD_DIR)/lib$(_NAMENOEXT).def
	-rm -f $(BLD_DIR)/lib$(_NAMENOEXT).a
	$(_Q)$(CC) -shared -Wl,--output-def="$(BLD_DIR)/lib$(_NAMENOEXT).def" -Wl,--out-implib="$(BLD_DIR)/lib$(_NAMENOEXT).a" -Wl,--dll $(_LIB_DIRS) $(OBJS) -o $@ -s $(_LINK_LIBRARIES) $(BUILD_FLAGS)
else
	$(_Q)$(CC) $(_LIB_DIRS) -o $@ $(OBJS) $(_LINK_LIBRARIES) $(BUILD_FLAGS)
endif

makebuild: $(_EXE)
	@echo '$(BUILD) build target is up to date.'

$(_DIRECTORIES):
	$(_Q)mkdir -p $@

.PHONY: clean
clean:
ifeq ($(CLEAN_OUTPUT),true)
	@echo 'Cleaning old build files & folders...'
	@echo
endif
	$(_Q)$(RM) $(_EXE)
	$(_Q)$(RM) $(DEPS)
	$(_Q)$(RM) $(OBJS)

#==============================================================================
# Production recipes
rmprod:
	-$(_Q)rm -f -r $(PRODUCTION_FOLDER)

mkdirprod:
	$(_Q)mkdir -p $(PRODUCTION_FOLDER)

releasetoprod: $(_EXE)
	$(_Q)$(_Q)cp $(_EXE) $(PRODUCTION_FOLDER)

makeproduction: rmprod mkdirprod releasetoprod
	@echo -n 'Adding dynamic libraries & project dependencies...'
	$(foreach dep,$(PRODUCTION_DEPENDENCIES),$(shell cp -r $(dep) $(PRODUCTION_FOLDER)))
	$(foreach excl,$(PRODUCTION_EXCLUDE),$(shell find $(PRODUCTION_FOLDER) -name '$(excl)' -delete))
	@echo ' Done'

#==============================================================================
# Dependency recipes
$(DEP_DIR)/%.d: ;
.PRECIOUS: $(DEP_DIR)/%.d

include $(wildcard $(DEPS))