#ifdef _WIN32
#include "WindowsHelper.hpp"

WindowsHelper::WindowsHelper()
{
	m_hIcon = LoadIcon(GetModuleHandle(nullptr), MAKEINTRESOURCE(WIN32_ICON_MAIN));
}

void WindowsHelper::setIcon(const sf::WindowHandle &inHandle)
{
	if(m_hIcon) {
		SendMessage(inHandle, WM_SETICON, ICON_BIG, (LPARAM)m_hIcon);
		SendMessage(inHandle, WM_SETICON, ICON_SMALL, (LPARAM)m_hIcon);
	}
}

#endif
