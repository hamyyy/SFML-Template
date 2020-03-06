#ifdef _WIN32
	#include "WindowsHelper.hpp"

	#include "Icon.h"

/******************************************************************************
 *
 *****************************************************************************/
WindowsHelper::WindowsHelper()
{
	// Get the icon directory
	PBYTE iconDirectory = getIconDirectory(WIN32_ICON_MAIN);

	// Store each icon
	std::array<int, 6> icons = { 16, 32, 48, 64, 128 };
	for (auto& it : icons)
	{
		HICON icon = getIconFromIconDirectory(iconDirectory, it);
		m_hIcons.push_back(icon);
	}
}

/******************************************************************************
 *
 *****************************************************************************/
WindowsHelper::~WindowsHelper()
{
	for (auto& it : m_hIcons)
	{
		if (it)
			DestroyIcon(it);
	}

	m_hIcons.clear();
}

/******************************************************************************
 * The window handle uses 32x32 (ICON_BIG) & 16x16 (ICON_SMALL) sized icons.
 * This should be called any time the SFML window is create/recreated
 *****************************************************************************/
void WindowsHelper::setIcon(HWND inHandle)
{
	float scalingFactor = getScreenScalingFactor(inHandle);
	std::size_t indexSmallIcon = static_cast<std::size_t>(std::min(std::max(std::ceil(scalingFactor - 1.0f), 0.0f), static_cast<float>(m_hIcons.size()) - 1.0f));
	std::size_t indexBigIcon = static_cast<std::size_t>(std::min(std::max(std::ceil(scalingFactor - 1.0f), 0.0f) + 1.0f, static_cast<float>(m_hIcons.size()) - 1.0f));

	if (m_hIcons[indexBigIcon])
		SendMessage(inHandle, WM_SETICON, ICON_BIG, (LPARAM)m_hIcons[indexBigIcon]);

	if (m_hIcons[indexSmallIcon])
		SendMessage(inHandle, WM_SETICON, ICON_SMALL, (LPARAM)m_hIcons[indexSmallIcon]);
}

/******************************************************************************
 *
 *****************************************************************************/
void WindowsHelper::toggleFullscreen(HWND inHandle, const sf::Uint32 inStyle, const bool inWindowed, const sf::Vector2u& inResolution)
{
	DWORD win32Style = sfmlWindowStyleToWin32WindowStyle(inStyle);
	UINT flags = SWP_DRAWFRAME | SWP_FRAMECHANGED;

	if (inWindowed)
	{
		// Window (centered on the focused screen)
		HDC screenDC = GetDC(inHandle);
		int screenWidth = GetDeviceCaps(screenDC, HORZRES);
		int screenHeight = GetDeviceCaps(screenDC, VERTRES);

		int width = static_cast<int>(inResolution.x);
		int height = static_cast<int>(inResolution.y);
		int left = (screenWidth - width) / 2;
		int top = (screenHeight - height) / 2;
		RECT rectangle = { 0, 0, width, height };
		AdjustWindowRect(&rectangle, win32Style, false);
		width = rectangle.right - rectangle.left;
		height = rectangle.bottom - rectangle.top;

		SetWindowLongPtr(inHandle, GWL_STYLE, win32Style);
		SetWindowLongPtr(inHandle, GWL_EXSTYLE, 0);
		SetWindowPos(inHandle, NULL, left, top, width, height, flags);
	}
	else
	{
		// Fullscreen
		int width = static_cast<int>(inResolution.x);
		int height = static_cast<int>(inResolution.y);

		// first time prevents the border from showing in the corner
		SetWindowPos(inHandle, HWND_TOP, 0, 0, width, height, flags);
		SetWindowLongPtr(inHandle, GWL_EXSTYLE, WS_EX_APPWINDOW);
		SetWindowLongPtr(inHandle, GWL_STYLE, win32Style);

		// second time cleans up the rect after the border has been removed
		SetWindowPos(inHandle, HWND_TOP, 0, 0, width, height, flags);

		// note: double SetWindowPos call isn't very effective on slower machines anyway :/
	}
	ShowWindow(inHandle, SW_SHOW);
}

/******************************************************************************
 * Gets the refresh rate of the device from the supplied handle
 *****************************************************************************/
int WindowsHelper::getRefreshRate(HWND inHandle)
{
	HDC screenDC = GetDC(inHandle);
	return GetDeviceCaps(screenDC, VREFRESH);
}

/******************************************************************************
 * Gets the screen scaling factor of the device from the supplied handle
 *****************************************************************************/
float WindowsHelper::getScreenScalingFactor(HWND inHandle)
{
	HDC screenDC = GetDC(inHandle);
	int logicalScreenHeight = GetDeviceCaps(screenDC, VERTRES);
	int physicalScreenHeight = GetDeviceCaps(screenDC, DESKTOPVERTRES);
	return static_cast<float>(physicalScreenHeight) / static_cast<float>(logicalScreenHeight);
}

/******************************************************************************
 * Loads a .ico file from The application's resources, and can contain multiple
 * sizes (for instance 16x16, 32x32 & 64x64). This is referred to as an
 * "Icon Directory". Additionally, it can have a single icon
 *****************************************************************************/
PBYTE WindowsHelper::getIconDirectory(const int inResourceId)
{
	HMODULE hModule = GetModuleHandle(nullptr);
	HRSRC hResource = FindResource(hModule, MAKEINTRESOURCE(inResourceId), RT_GROUP_ICON);

	HGLOBAL hData = LoadResource(hModule, hResource);
	PBYTE data = (PBYTE)LockResource(hData);

	return data;
}

/******************************************************************************
 * This will attempt to load a single icon from an icon directory
 * If the requested size isn't found, the first one is returned
 *****************************************************************************/
HICON WindowsHelper::getIconFromIconDirectory(PBYTE inIconDirectory, const uint inSize)
{
	HMODULE hModule = GetModuleHandle(nullptr);
	int resourceId = LookupIconIdFromDirectoryEx(inIconDirectory, TRUE, inSize, inSize, LR_DEFAULTCOLOR);
	HRSRC hResource = FindResource(hModule, MAKEINTRESOURCE(resourceId), RT_ICON);

	HGLOBAL hData = LoadResource(hModule, hResource);
	PBYTE data = (PBYTE)LockResource(hData);
	DWORD sizeofData = SizeofResource(hModule, hResource);

	HICON icon = CreateIconFromResourceEx(data, sizeofData, TRUE, 0x00030000, inSize, inSize, LR_DEFAULTCOLOR);
	return icon;
}

/******************************************************************************
 * Takes an SFML window style and matches it back to the Win32 equivalent
 *****************************************************************************/
DWORD WindowsHelper::sfmlWindowStyleToWin32WindowStyle(const sf::Uint32 inStyle)
{
	DWORD style = 0;
	// TODO: Exclusive fullscreen, if possible from here
	if (inStyle == sf::Style::None || inStyle == sf::Style::Fullscreen)
	{
		style = WS_VISIBLE | WS_POPUP | WS_CLIPCHILDREN | WS_CLIPSIBLINGS;
	}
	else
	{
		style = WS_VISIBLE;
		if (inStyle & sf::Style::Titlebar)
			style |= WS_CAPTION | WS_MINIMIZEBOX;
		if (inStyle & sf::Style::Resize)
			style |= WS_THICKFRAME | WS_MAXIMIZEBOX;
		if (inStyle & sf::Style::Close)
			style |= WS_SYSMENU;
	}

	return style;
}

#endif
