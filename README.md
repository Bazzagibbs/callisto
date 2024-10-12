# Callisto Engine

Desktop game engine written in [Odin](https://odin-lang.org).

[Engine documentation](https://bazzagibbs.com/docs) (WIP)

## Creating an application

**Please look at Callisto Sandbox for the most up-to-date usage of the engine.**

An example application can be found at [BazzaGibbs/callisto-sandbox](https://github.com/bazzagibbs/callisto-sandbox).

**THIS SECTION IS CURRENTLY BEING REWRITTEN**

## Building your application

The Callisto package must be placed in the root directory of your project.

```
<project>/
├── game_code.odin
├── callisto/
└── out/
    ├── game.exe (standalone)
    ├── game.dll (hot reload)
    └── runner.exe (hot reload)`
```

### Hot-reload development build

```bat
:: Build the runner executable
.\callisto\build-runner.bat
:: Build your game DLL
.\callisto\hot-reload.bat
:: Run the game
.\out\runner.exe

:: Make changes to the gameplay code while the game is running
.\callisto\hot-reload.bat
```

### Standalone build

```bat
:: Make a build without hot-reloading for release
.\callisto\build-standalone-release.bat
:: or with debug symbols
.\callisto\build-standalone-debug.bat

:: Run the game
.\out\game.exe
```

## In progress

- Runner and hot reloading

## Project Plan

- Input abstraction
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
