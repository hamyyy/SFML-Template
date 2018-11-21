#include "ResourcesBundle.hpp"

void initBundle()
{
#ifdef __APPLE__
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL(mainBundle);
    char path[PATH_MAX];
    if (!CFURLGetFileSystemRepresentation(resourcesURL, TRUE, (UInt8 *)path, PATH_MAX))
    {
        // error!
    }
    CFRelease(resourcesURL);

    std::string pathStr(path);
    std::size_t found = pathStr.find(".app");
    if (found!=std::string::npos)
        chdir(path);

#endif
}