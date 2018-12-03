#ifndef MAIN_HPP
#define MAIN_HPP

#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>

#include <iostream>

#ifdef __APPLE__
	#include "MacOS/CFResourcesBundle.hpp"
	CFResourcesBundle __macAppBundle;
#endif // __APPLE__

#endif // MAIN_HPP