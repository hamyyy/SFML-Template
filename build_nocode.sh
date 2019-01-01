
dec=\=\=\=\=\=\=
valid_platforms() {
	echo '       Valid options are: windows linux osx'
}

detect_platform() {
	if [[ $1 != '' ]]; then
		export PLATFORM=$1
	else
		if [[ $OSTYPE == "linux-gnu" || $OSTYPE == "cygwin" ]]; then
			export PLATFORM=linux
		elif [[ $OSTYPE == "darwin"* ]]; then
			export PLATFORM=osx
		elif [[ $OSTYPE == "msys" || $OSTYPE == "win32" ]]; then
			export PLATFORM=windows
		fi
	fi
}

detect_platform $1

if [[ $PLATFORM == 'windows' || $PLATFORM == 'linux' || $PLATFORM == 'osx' ]]; then
	cwd=${PWD##*/}
	export PROF_EXEC=gprof

	if [[ $PLATFORM == 'windows' ]]; then
		export PATH="$PATH:/c/mingw32/bin:/c/SFML-2.5.1/bin"
		export NAME=$cwd.exe
		export MAKE_EXEC=mingw32-make
	elif [[ $PLATFORM == 'linux' ]]; then
		export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
		export NAME=$cwd
		export MAKE_EXEC=make
	elif [[ $PLATFORM == 'osx' ]]; then
		export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
		export NAME=$cwd
		export MAKE_EXEC=make
	fi

	# echo $PATH
	# echo $NAME
	# echo $MAKE_EXEC
	# echo $PLATFORM
	# echo $PROF_EXEC

	bash ./build.sh buildprod Release
else
	tput setaf 1
	tput bold
	echo $dec Build Failed: Invalid platform \(parameter 1\) $dec
	valid_platforms
	tput sgr0
fi