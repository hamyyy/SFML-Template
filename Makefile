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
PRODUCTION_FOLDER_RESOURCES := $(PRODUCTION_FOLDER)

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
SOURCE_FILES := $(patsubst src/%,%,$(shell find src -name '*.cpp' -o -name '*.c' -o -name '*.cc' -o -name '*.rc'))
# Project subdirectories within src/ that contain source files
PROJECT_DIRS := $(patsubst src/%,%,$(shell find src -mindepth 1 -maxdepth 99 -type d))

# Add prefixes to the above variables
_LIB_DIRS := $(LIB_DIRS:%=-L%)
_INCLUDE_DIRS := $(patsubst %,-I%,src/ $(INCLUDE_DIRS))

_BUILD_MACROS := $(BUILD_MACROS:%=-D%)
_LINK_LIBRARIES := $(LINK_LIBRARIES:%=-l%)

#==============================================================================
# MacOS Specific
MACOS_ICON?=icon
PRODUCTION_MACOS_BUNDLE_COMPANY?=developer
PRODUCTION_MACOS_BUNDLE_DISPLAY_NAME?=App
PRODUCTION_MACOS_BUNDLE_NAME?=App

ifeq ($(PLATFORM),osx)
	PRODUCTION_FOLDER_MACOS := $(PRODUCTION_FOLDER)
	PRODUCTION_FOLDER := $(PRODUCTION_FOLDER)/$(PRODUCTION_MACOS_BUNDLE_NAME).app/Contents
	PRODUCTION_FOLDER_RESOURCES := $(PRODUCTION_FOLDER)/Resources
	PRODUCTION_DEPENDENCIES := $(PRODUCTION_DEPENDENCIES)
	PRODUCTION_MACOS_FRAMEWORKS := $(PRODUCTION_MACOS_FRAMEWORKS:%=%.framework)
endif

#==============================================================================
# Directories & Dependencies
BLD_DIR := bin/$(BUILD)
BLD_DIR := $(BLD_DIR:%/=%)
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
_OBJS := $(_OBJS:.cc=.o)
OBJS := $(_OBJS:%=$(OBJ_DIR)/%)
OBJ_SUBDIRS := $(PROJECT_DIRS:%=$(OBJ_DIR)/%)

DEP_DIR := $(BLD_DIR)/dep
ifeq ($(PLATFORM),windows)
	_DEPS := $(SOURCE_FILES:.rc=.res)
else
	_DEPS := $(SOURCE_FILES:%.rc=)
endif
_DEPS := $(_DEPS:.c=.d)
_DEPS := $(_DEPS:.cpp=.d)
_DEPS := $(_DEPS:.cc=.d)
DEPS := $(_DEPS:%=$(DEP_DIR)/%)
DEP_SUBDIRS := $(PROJECT_DIRS:%=$(DEP_DIR)/%)

ifeq ($(DUMP_ASSEMBLY),true)
	ASM_DIR := $(BLD_DIR)/asm
	_ASMS := $(_OBJS:%.res=)
	_ASMS := $(_ASMS:.o=.o.asm)
	ASMS := $(_ASMS:%=$(ASM_DIR)/%)
	ASM_SUBDIRS := $(PROJECT_DIRS:%=$(ASM_DIR)/%)
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
CFLAGS_ALL?=-Wfatal-errors -Wextra -Wall
CFLAGS?=-g $(CFLAGS_ALL)
CFLAGS_DEPS=-MT $@ -MMD -MP -MF $(DEP_DIR)/$*.Td

OBJ_COMPILE = $(CC) $(CFLAGS_DEPS) $(_BUILD_MACROS) $(CFLAGS) -fdiagnostics-color=always $(_INCLUDE_DIRS) -o $@ -c $<
RC_COMPILE = -$(RC) -J rc -O coff -i $< -o $@
ASM_COMPILE = objdump -d -C -Mintel $< > $@
POST_COMPILE = @mv -f $(DEP_DIR)/$*.Td $(DEP_DIR)/$*.d && touch $@

export GCC_COLORS := error=01;31:warning=01;33:note=01;36:locus=00;34

define color_reset
	@tput setaf 4
endef

#==============================================================================
# Build Scripts
all:
	@$(MAKE) -j$(MAX_PARALLEL_JOBS) -k --no-print-directory makebuild

rebuild: clean all

buildprod: all makeproduction

#==============================================================================

# Build Recipes
$(OBJ_DIR)/%.o: src/%.c
$(OBJ_DIR)/%.o: src/%.c $(DEP_DIR)/%.d | $(_DIRECTORIES)
	$(call color_reset)
ifeq ($(CLEAN_OUTPUT),true)
	@echo $(<:$(OBJ_DIR)/%=%)
endif
	$(_Q)$(OBJ_COMPILE)
	$(POST_COMPILE)

$(OBJ_DIR)/%.o: src/%.cpp
$(OBJ_DIR)/%.o: src/%.cpp $(DEP_DIR)/%.d | $(_DIRECTORIES)
	$(call color_reset)
ifeq ($(CLEAN_OUTPUT),true)
	@echo $(<:$(OBJ_DIR)/%=%)
endif
	$(_Q)$(OBJ_COMPILE)
	$(POST_COMPILE)

$(OBJ_DIR)/%.o: src/%.cc
$(OBJ_DIR)/%.o: src/%.cc $(DEP_DIR)/%.d | $(_DIRECTORIES)
	$(call color_reset)
ifeq ($(CLEAN_OUTPUT),true)
	@echo $(<:$(OBJ_DIR)/%=%)
endif
	$(_Q)$(OBJ_COMPILE)
	$(POST_COMPILE)

$(OBJ_DIR)/%.res: src/%.rc
$(OBJ_DIR)/%.res: src/%.rc src/%.h | $(_DIRECTORIES)
	$(call color_reset)
ifeq ($(CLEAN_OUTPUT),true)
	@echo $(<:$(OBJ_DIR)/%=%)
endif
	$(_Q)$(RC_COMPILE)

$(ASM_DIR)/%.o.asm: $(OBJ_DIR)/%.o
ifeq ($(CLEAN_OUTPUT),false)
	$(call color_reset)
endif
	$(_Q)$(ASM_COMPILE)

$(BLD_DIR)/%.dll:
	$(call color_reset)
	$(foreach dep,$(BUILD_DEPENDENCIES),$(shell cp -r $(dep) $(BLD_DIR)))

$(BLD_DIR)/%.so:
	$(call color_reset)
	$(foreach dep,$(BUILD_DEPENDENCIES),$(shell cp -r $(dep) $(BLD_DIR)))

$(_EXE): $(OBJS) $(ASMS) $(BLD_DIR) $(_BUILD_DEPENDENCIES)
	$(call color_reset)
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
	$(call color_reset)
	@echo '$(BUILD) build target is up to date.'

$(_DIRECTORIES):
ifeq ($(CLEAN_OUTPUT),false)
	$(call color_reset)
endif
	$(_Q)mkdir -p $@

.PHONY: clean
clean:
	$(call color_reset)
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
	$(call color_reset)
ifeq ($(PLATFORM),osx)
	-$(_Q)rm -f -r $(PRODUCTION_FOLDER_MACOS)
else
	-$(_Q)rm -f -r $(PRODUCTION_FOLDER)
endif

mkdirprod:
	$(call color_reset)
	$(_Q)mkdir -p $(PRODUCTION_FOLDER)

releasetoprod: $(_EXE)
	$(call color_reset)
ifeq ($(PLATFORM),osx)
	@echo 'Look ma, no Xcode!'
	@echo 'Creating the MacOS application bundle...'
	$(_Q)mkdir -p $(PRODUCTION_FOLDER)/Resources
	$(_Q)mkdir -p $(PRODUCTION_FOLDER)/Frameworks
	$(_Q)mkdir -p $(PRODUCTION_FOLDER)/MacOS
ifeq ($(shell brew ls --versions makeicns),)
	brew install makeicns
	$(call color_reset)
endif
	$(_Q)makeicns -in env/osx/$(MACOS_ICON).png -out $(PRODUCTION_FOLDER)/Resources/$(MACOS_ICON).icns
	$(_Q)plutil -convert binary1 env/osx/Info.plist.json -o $(PRODUCTION_FOLDER)/Info.plist
	$(_Q)plutil -replace CFBundleExecutable -string $(NAME) $(PRODUCTION_FOLDER)/Info.plist
	$(_Q)plutil -replace CFBundleName -string $(PRODUCTION_MACOS_BUNDLE_NAME) $(PRODUCTION_FOLDER)/Info.plist
	$(_Q)plutil -replace CFBundleDisplayName -string "$(PRODUCTION_MACOS_BUNDLE_DISPLAY_NAME)" $(PRODUCTION_FOLDER)/Info.plist
	$(_Q)plutil -replace CFBundleIdentifier -string com.$(PRODUCTION_MACOS_BUNDLE_DEVELOPER).$(PRODUCTION_MACOS_BUNDLE_NAME) $(PRODUCTION_FOLDER)/Info.plist
	$(_Q)cp $(_EXE) $(PRODUCTION_FOLDER)/MacOS
else
	$(_Q)cp $(_EXE) $(PRODUCTION_FOLDER)
endif

makeproduction: rmprod mkdirprod releasetoprod
	$(call color_reset)
	@echo -n 'Adding dynamic libraries & project dependencies...'
	$(foreach dep,$(PRODUCTION_DEPENDENCIES),$(shell cp -r $(dep) $(PRODUCTION_FOLDER_RESOURCES)))
	$(foreach excl,$(PRODUCTION_EXCLUDE),$(shell find $(PRODUCTION_FOLDER_RESOURCES) -name '$(excl)' -delete))
	@echo ' Done'
	@echo 'Creating the dmg image for the application...'
ifeq ($(PLATFORM),osx)
	$(foreach framework,$(PRODUCTION_MACOS_FRAMEWORKS),$(shell cp -r /Library/Frameworks/$(framework) $(PRODUCTION_FOLDER)/Frameworks))
	$(_Q)hdiutil create -megabytes 54 -fs HFS+ -volname $(PRODUCTION_MACOS_BUNDLE_NAME) $(PRODUCTION_FOLDER_MACOS)/$(PRODUCTION_MACOS_BUNDLE_NAME).dmg
	$(_Q)hdiutil mount $(PRODUCTION_FOLDER_MACOS)/$(PRODUCTION_MACOS_BUNDLE_NAME).dmg
	$(_Q)cp -r $(PRODUCTION_FOLDER_MACOS)/$(PRODUCTION_MACOS_BUNDLE_NAME).app /Volumes/$(PRODUCTION_MACOS_BUNDLE_NAME)/
	$(_Q)hdiutil unmount /Volumes/$(PRODUCTION_MACOS_BUNDLE_NAME)/
endif

#==============================================================================
# Dependency recipes
$(DEP_DIR)/%.d: ;
.PRECIOUS: $(DEP_DIR)/%.d

include $(wildcard $(DEPS))