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
#if defined(__APPLE__)
	#if __clang_major__ >= 9
namespace fs = std::filesystem;
	#else
namespace fs = std::experimental::filesystem::v1;
	#endif
#else
	#if __GNUC__ >= 8
namespace fs = std::filesystem;
	#else
namespace fs = std::experimental::filesystem::v1;
	#endif
#endif
}

#endif // UTIL_FILE_SYSTEM_HPP
