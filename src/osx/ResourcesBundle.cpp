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

    bool result = false;
    CFStringFindWithOptions((UInt8 *)path, CFSTR(".app"), PATH_MAX, CFStringCompareFlags::compareBackwards, result);
    if (result)
        chdir(path);

#endif
}