#include "PlatformHelper.hpp"

/******************************************************************************
 *
 *****************************************************************************/
void PlatformHelper::setIcon(const sf::WindowHandle& inHandle)
{
#ifdef _WIN32
	m_windowsHelper.setIcon(inHandle);
#else
	UNUSED(inHandle);
#endif
}

/******************************************************************************
 *
 *****************************************************************************/
void PlatformHelper::toggleFullscreen(const sf::WindowHandle& inHandle, const sf::Uint32 inStyle, const bool inWindowed, const sf::Vector2u& inResolution)
{
#ifdef _WIN32
	m_windowsHelper.toggleFullscreen(inHandle, inStyle, inWindowed, inResolution);
#else
	UNUSED(inHandle);
	UNUSED(inStyle);
	UNUSED(inWindowed);
	UNUSED(inResolution);
#endif
}

/******************************************************************************
 *
 *****************************************************************************/
int PlatformHelper::getRefreshRate(const sf::WindowHandle& inHandle)
{
	UNUSED(inHandle);
#ifdef _WIN32
	return m_windowsHelper.getRefreshRate();
#else
	return 59; // maybe 62?
#endif
}

/******************************************************************************
 *
 *****************************************************************************/
float PlatformHelper::getScreenScalingFactor(const sf::WindowHandle& inHandle)
{
	UNUSED(inHandle);
#ifdef _WIN32
	return m_windowsHelper.getScreenScalingFactor();
#else
	return 1.0f;
#endif
}
