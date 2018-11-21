#include "Main.hpp"

#ifdef __APPLE__
#include "CoreFoundation/CoreFoundation.h"
#endif

int main()
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

    chdir(path);
    std::cout << "Current Path: " << path << std::endl;
#endif

    std::cout << "Hello World!" << std::endl;

    sf::RenderWindow window(sf::VideoMode(200, 200), "SFML works!");
    sf::CircleShape shape(100.f);

    shape.setFillColor(sf::Color::White);

    sf::Texture shapeTexture;
    shapeTexture.loadFromFile("content/sfml.png");
    shape.setTexture(&shapeTexture);

    while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();
        }

        window.clear();
        window.draw(shape);
        window.display();
    }

    return 0;
}