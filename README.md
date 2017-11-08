# sfml-vscode-boilerplate
An SFML 2.4.2 C++14 configuration for Visual Studio Code (on Windows)

## Prerequisites

* [SFML 2.4.2 - GCC 6.1.0 MinGW (DW2) 32-bit](https://www.sfml-dev.org/files/SFML-2.4.2-windows-gcc-6.1.0-mingw-32-bit.zip)
* [GCC 6.1.0 MinGW (DW2)](https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/mingw-builds/6.1.0/threads-posix/dwarf/i686-6.1.0-release-posix-dwarf-rt_v5-rev0.7z/download)
* [Clang - From LLVM 5.0.0 package](http://releases.llvm.org/5.0.0/LLVM-5.0.0-win64.exe)
* [Visual Studio Code (Windows version)](https://code.visualstudio.com/download)
  * [Official C/C++ Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
  * [C/C++ Clang Command Adapter Extension](https://marketplace.visualstudio.com/items?itemName=mitaki28.vscode-clang)
  * [Include Autocomplete Extension](https://marketplace.visualstudio.com/items?itemName=ajshort.include-autocomplete)

## Installation

1. Download & Extract SFML to **C:\\SFML-2.4.2\\** where the bin/lib/include folders are contained within
2. Download & Extract MinGW to **C:\\mingw-w64\\** where the bin/lib/include folders are contained within
3. Download & Install LLVM (64-bit version) to the default directory (**C:\\Program Files\\LLVM\\**). clang.exe will be referenced from the bin folder within later on.
4. Go into your environment variables (**Start/Win Key** > type **environment variables** and select **edit the system environment variables** followed by the **Environment Variables...** button in the window that comes up. In the next window, under **System Variables**, double-click on **PATH** and add **C:\mingw-w64\bin**. Then, take out any other compiler variations you might have (**TDM-GCC-32\bin**, **CodeBlocks\MinGW\bin**) so that there are no conflicts. Obviously, if you still want to use these other compilers, you'll need to figure out your own solution.
5. Download & Install Visual Studio Code if you don't already have it.
6. Install the official **C/C++** Extension, reload the window & wait for the dependencies to install.
7. Install the **C/C++ Clang Command Adapter** extension. This will replace the default auto-complete functionality from the C/C++ Extension (it's buggy/slow).
8. Install the **Include Autocomplete** extension. This leverages the **"includePath"** array in **c\_cpp\_properties.json** for additional auto-complete functionality for #include

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

1. Open the Makefile. The only two variables you should be concerned about at this point are **\_SRCS** & **\_LLS** at the very top. Add .cpp files to the **\_SRCS** separated by a space character. Example:
```
_SRS=Main.cpp Window.cpp Character.cpp libs/Collision.cpp libs/ParticleSystem.cpp
```

2. Add any additional link libraries you need to the **\_LLS** variable, prefixed with **-l** and separated by a space character. Example:
```
_LLS=-lXInput -luser32 -lsomething
```

## Include directories & .vscode folder

If you need to add additional external libraries, these are a couple different places to keep in mind.

* **.vscode\\c\_cpp\_properties.json** - You'll see **"includePath"** & **"browse.path"** which look very similar, but one can search directories recursively and another cannot. Both contain the default search directories for the GCC 6.1.0 MinGW compiler, along with SFML's directory. Add addtional libraries to both sections for consistency, but includePath is the only one used out of the box.

  * **_"includePath"_** - Used by the C/C++ plugin if **"C_Cpp.intelliSenseEngine"** is set to **"Default"** in settings.json. includePath is also used by the **Include Autocomplete** plugin.
  * **_"browse.path"_** - Can be largely ignored in this config. Only used if **"C_Cpp.intelliSenseEngine"** is set to **"Tag Parser"** from what I understand. Can search directories recursively, so you can put a **\\\*** after large include directories

* **.vscode\\settings.json** - Contain all of your workspace settings & overrides VS Code's main settings.json. Here are some settings of interest:

  * **_"clang.cxxflags"_** - Contain the search directories for the Clang extension's auto-complete. Any time you add a directory to "includePath", add it here too, but with **-I** in front of it, surrounded by quotes, separated by commas (VS Code will let you know if there's a general .json syntax error if you're not familiar).
  * **_"files.exclude"_** - Add any filetypes you want to exclude from the folder panel.
  * **_"files.encoding"_** - This uses the same encoding as CodeBlocks (**windows1252**), but feel free to change it to suit your needs.
  * **_"editor.fontFamily"_** - I set this to Courier by default to that CodeBlocks feel. Change/remove this line if you want to stick to VS Code's default (Consolas), or your own preference. Same with **"editor.fontSize"** & **"editor.lineHeight"**.

* **.vscode\\launch.json** - Used to store the configuration to launch the debugger.
* **.vscode\\tasks.json** - Used to store the task definitions (Build & Run commands, etc.).
* **.vscode\\_keybindings.json** - As mentioned before, this is used purely to store handy keybindings that one can add themselves, and not recognized by VS Code.

## Notes

* This configuration assumes all source files are contained within the **src** folder, but uses the **root** as the working directory for assets & things referenced in your project.
* By default, this configuration uses the C++14 standard. If you want to use 11, you can change it in the **Makefile** & **"clang.cxxflags"** in settings.json.
* Feel free to offer suggestions/report issues if there's anything I missed, or could do better.
* This will be an ongoing project that I'll try to update as new SFML versions come out. Updating SFML releases should be relatively painless as I'll keep the Prereqs up to date as well.


That should be all you need to get started. Happy game making!