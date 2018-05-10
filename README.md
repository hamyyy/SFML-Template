# sfml-vscode-boilerplate
An SFML 2.5.0 C++14 configuration for Visual Studio Code (on Windows)

## Prerequisites

* [SFML 2.5.0 - MinGW (GCC) 7.3.0 DW2 32-bit](https://www.sfml-dev.org/files/SFML-2.5.0-windows-gcc-7.3.0-mingw-32-bit.zip)
* [MinGW (GCC) 7.3.0 DW2 32-bit](https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/mingw-builds/7.3.0/threads-posix/dwarf/i686-7.3.0-release-posix-dwarf-rt_v5-rev0.7z/download)
* [Visual Studio Code (Windows version)](https://code.visualstudio.com/download)
  * [Official C/C++ Extension (0.17.0+)](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
  * [Include Autocomplete Extension](https://marketplace.visualstudio.com/items?itemName=ajshort.include-autocomplete)
* [Git Bash (for Windows) ](https://git-scm.com/downloads)

## Installation

1. Download & Extract SFML to **C:\\SFML-2.5.0\\** where the bin, lib, include folders are contained within.
2. Download & Extract MinGW to **C:\\mingw32\\** where the bin, lib, include folders are contained within.
3. Go into your environment variables (**Start/Win Key** > type **environment variables** and select **edit the system environment variables** followed by the **Environment Variables...** button in the window that comes up. In the next window, under **System Variables**, double-click on **PATH** and add **C:\\mingw32\\bin**. Then, take out any other compiler variations you might have (TDM-GCC-32\bin, CodeBlocks\MinGW\bin) so that there are no conflicts. Obviously, if you still want to use these other compilers, you'll need to figure out your own solution.
4. Download & Install Visual Studio Code if you don't already have it.
5. Install the official **C/C++** Extension, reload the window & wait for the dependencies to install.
6. Install the **Include Autocomplete** extension. This leverages the **"includePath"** array in **c\_cpp\_properties.json** for additional auto-complete functionality when writing "#include ..."
7. If on Windows, install **Git Bash**, and ensure the **"terminal.integrated.shell.windows"** property in the project's **settings.json** is set to **bash.exe**'s correct location. We'll be using this for the terminal in our workspace so that the Makefile can run in both Windows, Mac & Linux (although Mac configuration is untested thus far)

## Configuration

At this point, everything you need is installed

1. Open the **sfml-vscode-boilerplate** folder in VS Code. You should see an lime-green status bar at the bottom (color-picked from the SFML logo).
2. You should be able to run a build task (**Ctrl+Shift+B** > **Build & Run**), but it'll be nicer to add keybindings for these so you can build with 1 keypress.
3. Open the .vscode folder and click on the **\_keybindings.json** file. This is not an officially recognized file, but just contains the keybindings you can copy into the actual keybindings.json file.
4. Go into **File** > **Preferences** > **Keyboard Shortcuts** & click on the keybindings.json link at the top.
5. Copy the keybindings into this file. Feel free to change them if you don't like them later.
6. The **F9** key will run the **Build & Run: Release** task. It should run the Makefile, find the compiler, build the Main.cpp into Main.o (as well as create a dependency file), and launch the green circle hello world that you should recognize from the official SFML guide. **Shift+F9** will launch **Run: Release**.
7. Similarly, **F10** will launch **Build & Run: Debug**. and any logging will be outputted into the integrated terminal instead of a separate console window.
8. **F8** will launch the actual Debugger, which first runs **Build & Run: Debug**.
9. If needed, you can rebuild either with **Ctrl+Shift+B** > **Rebuild: Release/Debug**. This is useful if you're changing compilers, SFML versions, or just want to make sure the build is fresh.

## Adding source files & libraries

If you're moving to this from CodeBlocks, think of this part as defining what's in your project. The src files might already exist somewhere, but you need to tell the compiler to include them. 

Open **tasks.json**. In **options > env**, you'll see 7 environment variables that will require settings specific to your projects. Each one is outlined below:

**SOURCE_FILES**: Add **.cpp** or **.rc** files relative to the **src/** directory, separated by a space character.
```
"SOURCE_FILES": "Main.cpp WindowManager.cpp Game/Character.cpp Graphics/ParticleSystem.cpp Utility/Geometry.cpp SceneManager/SceneManager.cpp SceneManager/Scene.cpp SceneManager/Scenes/SceneTitle.cpp"
```

**PROJECT_DIRS**: Add any subfolders you're using within the **src/** directory, separated by a space.
```
"PROJECT_DIRS": "Game Graphics Utility SceneManager SceneManager/Scenes"
```

**LIB_DIRS**: Add any additional lib directories (full path), separated by a space.
```
"LIB_DIRS": "C:/sfeMovie/lib C:/myLibraries/lib"
```

**INCLUDE_DIRS**: Add any additional include directories (full path), separated by a space.
```
"INCLUDE_DIRS": "C:/sfeMovie/include C:/myLibraries/include"
```

**LINK_LIBRARIES**: Add any additional link libraries, separated by a space.
```
"LINK_LIBRARIES": "XInput user32"
```

**FLAGS_RELEASE**: Additional compiler flags for the Release build (including prefix), separated by a space.
```
"FLAGS_RELEASE": "-mwindows"
```

**FLAGS_DEBUG**: Additional compiler flags for the Debug build (including prefix), separated by a space.
```
"FLAGS_DEBUG": "-fdiagnostics-color=auto"
```

Note: You do not need to add SFML to any of these variables, since it's already included in the Makefile. In fact, you shouldn't have to edit the Makefile (unless you want to add new recipes to it of course).

Note 2: You can add any of these variables to **(platform) > options > env** for platform specific libraries, etc.

Note 3: Even though this is primarily a Windows environment, all file paths will use forward slashes since we're using bash instead of powershell. This makes for less headaches if/when you decide to go cross-platform.

## Include directories & .vscode folder

If you need to add additional external libraries, these are a couple different places to keep in mind.

* **.vscode\\c\_cpp\_properties.json** - You'll see **"includePath"** & **"browse.path"**. Both already include the default search directories for the MinGW compiler via the **compilerPath** property, so the includePath can just contain SFML and project-related paths. Add addtional libraries to both sections for consistency, but includePath is the only one used out of the box. See details below.

  * _"includePath"_ - Used by the C/C++ extension if **"C_Cpp.intelliSenseEngine"** is set to **"Default"** in settings.json. includePath is also used by the **Include Autocomplete** extension. Add directories recursively with **\\****
  * _"browse.path"_ - Only used if **"C_Cpp.intelliSenseEngine"** is set to **"Tag Parser"** from what I understand. Add directories recursively with **\\***

* **.vscode\\settings.json** - Contains all of your **Workspace Settings** & overrides the main **User Settings**. Here are some of interest:

  * _"files.exclude"_ - Add any filetypes you want to exclude from the folder panel.
  * _"files.encoding"_ - This uses the same encoding as CodeBlocks (**windows1252**), but feel free to change it to suit your needs.
  * _"editor.fontFamily"_ - I set this to Courier by default to that CodeBlocks feel. Change/remove this line if you want to stick to VS Code's default (Consolas), or your own preference. Same with _"editor.fontSize"_ & _"editor.lineHeight"_.

* **.vscode\\launch.json** - Used to store the configuration to launch the debugger.
* **.vscode\\tasks.json** - Used to store the task definitions (Build & Run commands, etc.).
* **.vscode\\_keybindings.json** - As mentioned before, this file is used purely to store handy keybindings that one can add themselves, and not actually recognized by VS Code.

## Notes

* This configuration assumes all source files are contained within the **src** folder, but uses the **root** as the working directory for assets & things referenced in your project.
* By default, this configuration uses C++14. You can change the compiler flags in **tasks.json** under **CFLAGS**.
* Feel free to offer suggestions/report issues if there's anything I missed, or could do better.
* This will be an ongoing project that I'll try to update as new SFML versions come out. Updating SFML releases should be relatively painless as I'll keep the Prereqs up to date as well.


That should be all you need to get started. Happy game making!