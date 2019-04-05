#ifndef LINUX_HELPER_HPP
#define LINUX_HELPER_HPP

#include <X11/Xlib.h>
#include <limits.h>
#include <unistd.h>

class LinuxHelper
{
	public:
		LinuxHelper();

	private:
		std::string current_path();
};

#endif // LINUX_HELPER_HPP
