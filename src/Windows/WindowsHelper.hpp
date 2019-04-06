#ifndef WIN32_HELPER_HPP
#define WIN32_HELPER_HPP

// Local includes
#include "Icon.h"

class WindowsHelper
{
	public:
		WindowsHelper();

		void setIcon(const sf::WindowHandle &handle);

	private:
        HICON m_hIcon;

};

#endif // WIN32_HELPER_HPP
