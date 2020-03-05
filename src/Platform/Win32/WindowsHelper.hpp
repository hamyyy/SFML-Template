#ifndef WINDOWS_HELPER_HPP
#define WINDOWS_HELPER_HPP

struct WindowsHelper
{
	WindowsHelper();

	void setIcon(HWND inHandle);

private:
	PBYTE getIconDirectory(const int inResourceId);
	HICON getIconFromIconDirectory(PBYTE inIconDirectory, const uint inSize);

	HICON m_hIcon32;
	HICON m_hIcon16;
};

#endif // WINDOWS_HELPER_HPP
