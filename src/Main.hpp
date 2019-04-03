#ifndef MAIN_HPP
#define MAIN_HPP

#ifdef __APPLE__
	#include "MacOS/CFResourcesBundle.hpp"
	CFResourcesBundle __macAppBundle;
#endif // __APPLE__

#ifdef __linux__
	#include "Linux/XInitThreadsHelper.hpp"
	XInitThreadsHelper __xinitThreadsHelper;
#endif // __linux__

//

#endif // MAIN_HPP
