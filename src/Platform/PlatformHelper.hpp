#ifndef PLATFORM_HELPER_HPP
#define PLATFORM_HELPER_HPP

#ifdef __APPLE__
	#include "MacOS/MacHelper.hpp"
#endif // __APPLE__

#ifdef __linux__
	#include "Linux/LinuxHelper.hpp"
#endif // __linux__

#ifdef _WIN32
	#include "Win32/WindowsHelper.hpp"
#endif // _WIN32

struct PlatformHelper
{
	void setIcon(const sf::WindowHandle& inHandle, const float inScaleFactor);
	void toggleFullscreen(const sf::WindowHandle& inHandle, const sf::Uint32 inStyle, const bool inWindowed, const sf::Vector2u& inResolution);
	int getRefreshRate(const sf::WindowHandle& inHandle);
	float getScreenScalingFactor(const sf::WindowHandle& inHandle);

private:
#ifdef __APPLE__
	MacHelper m_macHelper;
#endif // __APPLE__

#ifdef __linux__
	LinuxHelper m_linuxHelper;
#endif // __linux__

#ifdef _WIN32
	WindowsHelper m_windowsHelper;
#endif // _WIN32
};

#endif // PLATFORM_HELPER_HPP
