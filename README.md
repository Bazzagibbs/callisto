# Callisto Engine

Desktop game engine written in [Odin](https://odin-lang.org).

## Creating an application

An example application can be found at [Bazzas-Personal-Stuff/callisto-sandbox](https://github.com/bazzas-personal-stuff/callisto-sandbox).

Add the engine somewhere to your project and include it in your app. This example will assume the package is a direct child of your root directory, `project-root-dir/callisto/`

1. Initialize the engine
2. Perform your application code
3. Shutdown the engine

```odin
package main

include "callisto"

main :: proc() {
    ok := callisto.init(); if !ok do return
    defer callisto.shutdown()

    for callisto.should_loop() {
        loop()
    }  
}

loop :: proc() {
    // gameplay code here
}
```

## Using Callisto logger

After Callisto has been initialized, a logger is available to be used by your application.

```odin
package main
include "callisto"
include "core:log"

main :: proc() {
    // ...

    // context.logger only needs to be set once at the outermost scope of your application, 
    // e.g. the entry point
    context.logger = callisto.logger

    log.info("Hellope!")
}
```


## Implemented features

- Window abstraction
  - GLFW for desktop platforms
- Basic input forwarding
- Game loop
- Logger

## In progress

- Renderer abstraction
  - Vulkan implementation

## Project Plan

- glTF/glb model support
- HDRI skybox lighting
- Profiling (Spall)
- Audio
- SHIP A GAME
- Input abstraction / developer console
- WebGPU renderer implementation?