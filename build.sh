# echo $1
# echo $2

BUILD=$2


dec=\=\=\=\=\=\=

build_success() {
	tput setaf 2
	tput bold
	echo $dec Build Succeeded $dec
	tput sgr0
}

build_success_launch() {
	tput setaf 2
	tput bold
	echo $dec Build Succeeded: Launching bin/$BUILD/$NAME $dec
	tput sgr0
}

build_fail() {
	tput setaf 1
	tput bold
	echo $dec Build Failed: Review the compile errors above $dec
	tput sgr0
}

launch() {
	tput setaf 2
	tput bold
	echo $dec Launching bin/$BUILD/$NAME $dec
	tput sgr0
}

launch_prod() {
	tput setaf 2
	tput bold
	echo $dec Launching Production Build: $NAME $dec
	tput sgr0
}

profiler_done() {
	tput setaf 2
	tput bold
	echo $dec Profiler Completed: View $PROF_ANALYSIS_FILE for details $dec
	tput sgr0
}

profiler_error() {
	tput setaf 1
	tput bold
	echo $dec Error: Profiler must be run on Debug build. $dec
	tput sgr0
}

tput setaf 4
if [ $1 == 'buildrun' ] ; then
	if $MAKE_EXEC BUILD=$BUILD; then
		build_success_launch
		bin/$BUILD/$NAME
	else
		build_fail
	fi

elif [ $1 == 'build' ] ; then
	if $MAKE_EXEC BUILD=$BUILD; then
		build_success
	else
		build_fail
	fi

elif [ $1 == 'rebuild' ] ; then
	if $MAKE_EXEC BUILD=$BUILD rebuild; then
		build_success
	else
		build_fail
	fi

elif [ $1 == 'run' ] ; then
	launch
	bin/$BUILD/$NAME

elif [ $1 == 'buildprod' ] ; then
	if $MAKE_EXEC BUILD=$BUILD buildprod; then
		build_success
	else
		build_fail
	fi

elif [ $1 == 'profile' ] ; then
	if [ $BUILD == 'Debug' ] ; then
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
	echo Command not recognized
fi

tput sgr0