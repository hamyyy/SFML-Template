#ifdef __linux__
#include "LinuxHelper.hpp"

std::string LinuxHelper::current_path()
{
    char *path = static_cast<char*>(malloc(PATH_MAX));
    if (path != NULL)
    {
        if (readlink("/proc/self/exe", path, PATH_MAX) == -1)
        {
            free(path);
            path = NULL;
        }
    }
    if (path == NULL)
        return "";

    std::string ret(path);
    free(path);
    path = NULL;

    return ret;
}

LinuxHelper::LinuxHelper()
{
	XInitThreads();

	std::string path = current_path();
    if (path != "") {
        if (!chdir(path.c_str()))
            printf("Error: Working directory was not set correctly.");
    }
}
#endif
