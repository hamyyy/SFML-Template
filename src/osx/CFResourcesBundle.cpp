#include "CFResourcesBundle.hpp"

void initCFBundle()
{
#ifdef __APPLE__
    // This function ensures the working directory is set inside of the bundle if in production mode
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL(mainBundle);
    char path[PATH_MAX];
    bool pathSet = CFURLGetFileSystemRepresentation(resourcesURL, TRUE, (UInt8 *)path, PATH_MAX);
    // This is a copy, so we release it here
    CFRelease(resourcesURL);

    // Actually do the check here
    if (pathSet)
    {
        std::string pathStr = path;
        if (pathStr.find(".app") != std::string::npos)
            chdir(path);
    }

#endif
}