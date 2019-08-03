MAX_PARALLEL_JOBS := 8
CLEAN_OUTPUT := true
DUMP_ASSEMBLY := false

_CFLAGS_WARNINGS := -Wall -Wcast-align -Werror -Wextra -Wformat-nonliteral -Wformat=2 -Winvalid-pch -Wmissing-declarations -Wmissing-format-attribute -Wmissing-include-dirs -Wredundant-decls -Wredundant-decls -Wswitch-default -Wswitch-enum -Wodr
_CFLAGS_STD :=  -std=c++17

LINK_LIBRARIES := \
	sfml-graphics \
	sfml-audio \
	sfml-network \
	sfml-window \
	sfml-system

PRECOMPILED_HEADER := PCH

PRODUCTION_FOLDER := build

PRODUCTION_EXCLUDE := \
	*.psd \
	*.rar \
	*.7z \
	Thumbs.db \
	.DS_Store

PRODUCTION_DEPENDENCIES := \
	content

