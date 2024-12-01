# Callisto Engine

Desktop game engine written in [Odin](https://odin-lang.org).

[Engine documentation](https://bazzagibbs.com/docs) (WIP)

## Creating an application

**Please look at Callisto Sandbox for the most up-to-date usage of the engine.**

An example application can be found at [BazzaGibbs/callisto-sandbox](https://github.com/bazzagibbs/callisto-sandbox).
1. Clone this package to your project
    ```sh
    git clone --recursive --depth=1 https://github.com/Bazzagibbs/callisto.git
    ```
2. Modify the following values in `callisto/build.py`
    - `APP_NAME` - affects build filenames and persistent data path (default: "callisto_app")
    - `COMPANY_NAME` - affects persistent data path (default: "callisto_default_company")
    - (Optional) `ASSET_DIRECTORY` - location of the project's imported asset library relative to the project root (default: "./assets")
    - (Optional) `CALLISTO_DIRECTORY` - location of the Callisto package relative to the project root (default: "./callisto")
    - (Optional) `OUT_DIRECTORY` - output directory relative to the project's root. Can be overridden with `-out <dir>` argument. (default: "./out")
3. Define the following exported procedures:
    ```odin
    package my_project
    import "callisto"

    @(export)
    callisto_init :: proc (runner: ^callisto.Runner) {}

    @(export)
    callisto_destroy :: proc (user_data: rawptr) {}

    @(export)
    callisto_event :: proc (event: callisto.Event, user_data: rawptr) -> (handled: bool) {
        return false
    }

    @(export)
    callisto_loop :: proc (user_data: rawptr) {}
    ```
4. Ignore the following from version control:
    ```
    /out/
    ```

An example Callisto project may be structured like so:
```
my_project/
├── game_code.odin
├── assets/        # asset source files (fbx, png)
├── data/          # imported asset files (.cal)
├── callisto/
└── out/
```

## Building your application

A build script is provided in `callisto/build.py`. It may be copied to, or called from, your project's root directory.

```sh
cd my_project
py callisto\build.py --help
```

### Development (hot-reload) build

Development builds include debug symbols and hot-reload functionality.

```sh
# First time compiling, build runner exe and application dll
cd my_project
py callisto\build.py develop
.\out\callisto_app.exe

# While app is running the application DLL can be recompiled and reloaded
py callisto\build.py # or py callisto\build.py reload
```

### Debug build

Debug builds include debug symbols but no hot-reload functionality.
This may be desired for shipping playtest builds.

```sh
cd my_project
py callisto\build.py debug
```

### Release build

Release builds have no debug symbols or hot-reload functionality.
They also have a less verbose logger level (.Info) than debug builds (.Debug).

```sh
cd my_project
py callisto\build.py release
```

### Manual build

If you would rather write your own build script, these are the steps to build it manually:

```sh

# build application DLL with debug symbols
odin build . -debug -build-mode=shared -out=./out/<app_name>.dll -define:APP_NAME="<app_name> -define:COMPANY_NAME="<company_name>"

# other optional define flags for Application:
# -define:VERBOSE=true                # sets logger level to .Debug in release builds
# -define:PROFILER=true               # compile with profiler instrumentation
# -define:PROFILER_FILE="<file_name>" # sets the file to write Spall profiler logs to. This file will be placed in the app's persistent storage
```

```sh
# build runner executable with debug symbols + hot reload
odin build callisto/runner -debug -out=./out/<app_name>.exe -define:HOT_RELOAD=true -define:APP_NAME="<app_name>" -define:COMPANY_NAME="<company_name>"
```

```sh
# copy assets from ./data into output directory
cp ./data ./out/data
```

Note that when performing a hot-reload build of your application DLL, you should compile to a
temporary staging DLL file, then rename it once compilation is finished. The file watcher
may detect a modification to the output file while Odin is still using it.

e.g. `odin build ... -out=./out/staging.dll && mv ./out/staging.dll ./out/<app_name>.dll`

## Persistent storage

Persistent storage may be used to store user configuration, save files, log files, etc.
This directory is in the following location:

- Windows: `%LOCALAPPDATA%\<company_name>\<app_name>\`


## Current development state

### Complete

- Hot reloading
- Window creation


### In progress

- Platform layer (Windows)
    - Window events
    - Keyboard/Mouse input events


### Project Plan

- Input abstraction (Actions API)
- Renderer
- Developer console + convars
- Immediate-mode rendering for debug UI
- Asset saving and loading
- Retained 2D/UI/sprite rendering
- Maybe ECS for scene management - gameplay will probably be managed outside of the ECS
- HDRI skybox lighting
- Audio
- SHIP A GAME
- Physics (Jolt)
- Skinned meshes
- 3D animations
