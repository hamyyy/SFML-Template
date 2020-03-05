#include "PlatformHelper.hpp"

/******************************************************************************
 *
 *****************************************************************************/
void PlatformHelper::setIcon(const sf::WindowHandle& inHandle)
{
#ifdef _WIN32
	m_windowsHelper.setIcon(inHandle);
#endif
}
