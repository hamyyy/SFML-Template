#ifndef UTIL_FILE_SYSTEM_HPP
#define UTIL_FILE_SYSTEM_HPP

// std::filesystem
#if __GNUC__ >= 8
	#include <filesystem>
#else
	#include <experimental/filesystem>
#endif

namespace util
{
#if __GNUC__ >= 8
namespace fs = std::filesystem;
#else
namespace fs = std::experimental::filesystem::v1;
#endif
}

#endif // UTIL_FILE_SYSTEM_HPP
