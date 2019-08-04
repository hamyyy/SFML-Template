#!/bin/bash

CMD=$1
BUILD=$2
VSCODE=$3
OPTIONS=$4

cwd=${PWD##*/}

export GCC_COLORS="error=01;31:warning=01;33:note=01;36:locus=00;34"

if [[ $CMD == '' ]]; then
	CMD=buildprod
fi
if [[ $BUILD == '' ]]; then
	BUILD=Release
fi

if [[ $OSTYPE == 'linux-gnu'* || $OSTYPE == 'cygwin'* ]]; then
	if [[ $OSTYPE == 'linux-gnueabihf' ]]; then
		export PLATFORM=rpi
	else
		export PLATFORM=linux
	fi
	if [[ $NAME == '' ]]; then
		export NAME=$cwd
	fi
elif [[ $OSTYPE == 'darwin'* ]]; then
	export PLATFORM=osx
	if [[ $NAME == '' ]]; then
		export NAME=$cwd
	fi
elif [[ $OSTYPE == 'msys' || $OSTYPE == 'win32' ]]; then
	export PLATFORM=windows
	if [[ $NAME == '' ]]; then
		export NAME=$cwd.exe
	fi
fi


if [[ $VSCODE != 'vscode' ]]; then
	export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
	if [[ $PLATFORM == 'windows' ]]; then
		export PATH="/c/SFML-2.5.1/bin:/c/mingw32/bin:$PATH"
	else
		if [[ $PLATFORM == 'rpi' ]]; then
			export PATH="/usr/local/gcc-8.1.0/bin:$PATH"
		fi
	fi
	echo
	echo build.sh PATH=$PATH
	echo
fi

export MAKE_EXEC=make
if [[ $PLATFORM == 'windows' ]]; then
	if [ $(type -P "mingw32-make.exe") ]; then
		export MAKE_EXEC=mingw32-make.exe
	elif [ $(type -P "make.exe") ]; then
		export MAKE_EXEC=make.exe
	fi
fi

if [[ $BUILD != "Release" && $BUILD != 'Debug' && $BUILD != 'Tests' ]]; then
	BUILD=Release
fi

if [[ $BUILD == 'Tests' ]]; then
	NAME=tests_$NAME
fi

PROF_EXEC=gprof
PROF_ANALYSIS_FILE=profiler_analysis.stats

dec=\=\=\=\=\=\=

display_styled() {
	tput setaf $1
	tput bold
	echo $dec $2 $dec
	tput sgr0
}

build_success() {
	display_styled 2 "Build Succeeded"
}

build_success_launch() {
	display_styled 2 "Build Succeeded: Launching bin/$BUILD/$NAME"
	echo
}

build_fail() {
	display_styled 1 "Build Failed: Review the compile errors above"
	tput sgr0
	exit 1
}

build_prod_error() {
	display_styled 1 "Error: buildprod must be run on Release build."
	tput sgr0
	exit 1
}

launch() {
	display_styled 2 "Launching bin/$BUILD/$NAME"
	echo
}

launch_prod() {
	display_styled 2 "Launching Production Build: $NAME"
	echo
}

profiler_done() {
	display_styled 2 "Profiler Completed: View $PROF_ANALYSIS_FILE for details"
}

profiler_error() {
	display_styled 1 "Error: Profiler must be run on Debug build."
	tput sgr0
	exit 1
}

profiler_osx() {
	display_styled 1 "Error: Profiling (with gprof) is not supported on Mac OSX."
	tput sgr0
	exit 1
}

tput setaf 4
if [[ $CMD == 'buildrun' ]]; then
	if $MAKE_EXEC BUILD=$BUILD; then
		build_success_launch
		if [[ $BUILD == 'Tests' ]]; then
			bin/Release/$NAME $OPTIONS
		else
			bin/$BUILD/$NAME $OPTIONS
		fi
	else
		build_fail
	fi

elif [[ $CMD == 'build' ]]; then
	if $MAKE_EXEC BUILD=$BUILD; then
		build_success
	else
		build_fail
	fi

elif [[ $CMD == 'rebuild' ]]; then
	if $MAKE_EXEC BUILD=$BUILD rebuild; then
		build_success
	else
		build_fail
	fi

elif [[ $CMD == 'run' ]]; then
	launch
	if [[ $BUILD == 'Tests' ]]; then
		bin/Release/$NAME $OPTIONS
	else
		bin/$BUILD/$NAME $OPTIONS
	fi

elif [[ $CMD == 'buildprod' ]]; then
	if [[ $BUILD == 'Release' ]]; then
		if $MAKE_EXEC BUILD=$BUILD buildprod; then
			build_success
		else
			build_fail
		fi
	else
		build_prod_error
	fi

elif [[ $CMD == 'profile' ]]; then
	if [[ $PLATFORM == 'osx' ]]; then
		profiler_osx
	elif [[ $BUILD == 'Debug' ]]; then
		if $MAKE_EXEC BUILD=$BUILD; then
			build_success_launch
			tput sgr0
			bin/$BUILD/$NAME
			tput setaf 4
			gprof bin/Debug/$NAME gmon.out > $PROF_ANALYSIS_FILE
			profiler_done
		else
			build_fail
		fi
	else
		profiler_error
	fi

else
	tput setaf 1
	tput bold
	echo $dec Error: Command \"$CMD\" not recognized. $dec
	tput sgr0
	exit 1
fi

tput sgr0
exit 0