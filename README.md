# sfml-vscode-boilerplate
An SFML 2.4.2 C++14 configuration for Visual Studio Code (on Windows)

## Prerequisites

* [SFML 2.4.2 - GCC 6.1.0 MinGW (DW2) 32-bit](https://www.sfml-dev.org/files/SFML-2.4.2-windows-gcc-6.1.0-mingw-32-bit.zip)
* [GCC 6.1.0 MinGW (DW2)](https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/mingw-builds/6.1.0/threads-posix/dwarf/i686-6.1.0-release-posix-dwarf-rt_v5-rev0.7z/download)
* [Visual Studio Code (Windows version)](https://code.visualstudio.com/download)
  * [Official C/C++ Extension (0.17.0+)](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
  * [Include Autocomplete Extension](https://marketplace.visualstudio.com/items?itemName=ajshort.include-autocomplete)
* [Git Bash (for Windows) ](https://git-scm.com/downloads)

## Installation

1. Download & Extract SFML to **C:\\SFML-2.4.2\\** where the bin/lib/include folders are contained within
2. Download & Extract MinGW to **C:\\mingw-w64\\** where the bin/lib/include folders are contained within
3. Go into your environment variables (**Start/Win Key** > type **environment variables** and select **edit the system environment variables** followed by the **Environment Variables...** button in the window that comes up. In the next window, under **System Variables**, double-click on **PATH** and add **C:\mingw-w64\bin**. Then, take out any other compiler variations you might have (**TDM-GCC-32\bin**, **CodeBlocks\MinGW\bin**) so that there are no conflicts. Obviously, if you still want to use these other compilers, you'll need to figure out your own solution.
4. Download & Install Visual Studio Code if you don't already have it.
5. Install the official **C/C++** Extension, reload the window & wait for the dependencies to install.
6. Install the **Include Autocomplete** extension. This leverages the **"includePath"** array in **c\_cpp\_properties.json** for additional auto-complete functionality when writing "#include ..."
7. If on Windows, install **Git Bash**, and ensure the **"terminal.integrated.shell.windows"** property in the project's **settings.json** is set to **bash.exe**'s correct location. We'll be using this for the terminal in our workspace so that the Makefile can run in both Windows, Mac & Linux (although Mac configuration is untested thus far)

## Configuration

At this point, everything you need is installed

1. Open the **sfml-vscode-boilerplate** folder in VS Code. You should see an lime-green status bar at the bottom (color-picked from the SFML logo).
2. At this point you should be able to run a build task (**Ctrl+Shift+B** > **Build & Run**), but it'll be nicer to add keybindings for these tasks so you can build with 1 keypress.
3. Open the .vscode folder and click on the **\_keybindings.json** file. This is not an officially recognized file, but just contains the keybindings you can copy into the actual keybindings.json file.
4. Go into **File** > **Preferences** > **Keyboard Shortcuts** & click on the keybindings.json link at the top.
5. Copy the keybindings into this file. Feel free to change them if you don't like them later.
6. Hit the **F9** key to run the **Build & Run: Release** task. It should run the Makefile, find the compiler, build the Main.cpp into Main.o, and launch the green circle hello world that you should recognize from the official SFML guide. **Shift+F9** will launch the basic Debug build, and F8 will launch the actual Debugger along with the Debug build.

## Adding source files & libraries to the Makefile

If you're moving to this from CodeBlocks, think of this as adding files to your project. The src files might already be there, but you need to tell the compiler to include them.

1. Open the Makefile. The only three variables you should be concerned about at this point are **\_SRCS**, **\_SUBDIRS** & **\_LLS** at the very top.
2. Add **.cpp** or **.rc** files to the **\_SRCS** separated by a space character. Example:
```
_SRS=Main.cpp WindowManager.cpp Game/Character.cpp Graphics/ParticleSystem.cpp Utility/Collision.cpp 
```

3. Add any additional subfolders you have contained within src\ to the **\_SUBDIRS** variable, separated by a space character. Example:
```
_SUBDIRS=libs render net
```

4. Add any additional link libraries you need to the **\_LLS** variable, prefixed with **-l** and separated by a space character. Example:
```
_LLS=XInput user32 something
```

## Include directories & .vscode folder

If you need to add additional external libraries, these are a couple different places to keep in mind.

* **.vscode\\c\_cpp\_properties.json** - You'll see **"includePath"** & **"browse.path"**. Both already include the default search directories for the MinGW compiler via the **compilerPath** property, so the includePath can just contain SFML and project-related paths. Add addtional libraries to both sections for consistency, but includePath is the only one used out of the box. See details below.

  * **_"includePath"_** - Used by the C/C++ extension if **"C_Cpp.intelliSenseEngine"** is set to **"Default"** in settings.json. includePath is also used by the **Include Autocomplete** extension. Add directories recursively with *\\\*\**
  * **_"browse.path"_** - Only used if **"C_Cpp.intelliSenseEngine"** is set to **"Tag Parser"** from what I understand. Can search directories recursively, so you can put a **\\\*** after large include directories

* **.vscode\\settings.json** - Contain all of your workspace settings & overrides VS Code's main settings.json. Here are some settings of interest:

  * **_"files.exclude"_** - Add any filetypes you want to exclude from the folder panel.
  * **_"files.encoding"_** - This uses the same encoding as CodeBlocks (**windows1252**), but feel free to change it to suit your needs.
  * **_"editor.fontFamily"_** - I set this to Courier by default to that CodeBlocks feel. Change/remove this line if you want to stick to VS Code's default (Consolas), or your own preference. Same with **"editor.fontSize"** & **"editor.lineHeight"**.

* **.vscode\\launch.json** - Used to store the configuration to launch the debugger.
* **.vscode\\tasks.json** - Used to store the task definitions (Build & Run commands, etc.).
* **.vscode\\_keybindings.json** - As mentioned before, this is used purely to store handy keybindings that one can add themselves, and not recognized by VS Code.

## Notes

* This configuration assumes all source files are contained within the **src** folder, but uses the **root** as the working directory for assets & things referenced in your project.
* By default, this configuration uses the C++14 standard. You can change the compiler flags in **tasks.json** under **CFLAGS**.
* If for some reason after an update, the build scripts don't work, reinstall the C/C++ extension and it should work again (this was an issue in an older version of the extension anyway).
* Feel free to offer suggestions/report issues if there's anything I missed, or could do better.
* This will be an ongoing project that I'll try to update as new SFML versions come out. Updating SFML releases should be relatively painless as I'll keep the Prereqs up to date as well.


That should be all you need to get started. Happy game making!