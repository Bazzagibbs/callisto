# Callisto Engine

Desktop game engine written in [Odin](https://odin-lang.org).

[Engine documentation](https://docs.bazzagibbs.com/callisto) (WIP)

[Galileo asset format documentation](https://docs.bazzagibbs.com/galileo)

## Creating an application

**Please look at Callisto Sandbox for the most up-to-date usage of the engine.**

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

## Callisto Debug Utilities

Callisto provides a `debug` package that can help with debugging boilerplate.

```odin
package main
include "callisto"
include "core:log"
include "callisto/debug"

main :: proc() {
    
    when ODIN_DEBUG {
        context.logger = debug.create_logger()
        defer debug.destroy_logger(context.logger)

        // A tracking allocator that will print out any bad allocations and/or memory leaks when it is destroyed
        track := debug.create_tracking_allocator()
        context.allocator = mem.tracking_allocator(&track)
        defer debug.destroy_tracking_allocator(&track)
    }

    when config.DEBUG_PROFILER_ENABLED {
        // Spall profile trace that can be viewed in Spall Web: https://gravitymoth.com/spall/spall-web.html
        debug.create_profiler()
        defer debug.destroy_profiler()
    }

    log.info("Hellope!")
}
```

## Importing assets

Callisto loads assets using the [Galileo file format](https://docs.bazzagibbs.com/galileo).

Source assets such as glTF, png, etc. can be imported to the Galileo format using the [Callisto Editor](https://github.com/Bazzagibbs/callisto-editor) (WIP),
or using a custom implementation of the format specification.

## Implemented features

- Window abstraction
  - GLFW for desktop platforms
- Basic input forwarding
- Game loop
- Logger
- Profiling (Spall)

## In progress

- Renderer abstraction
  - Vulkan implementation
- Asset file format "Galileo" (.gali)

## Project Plan

- HDRI skybox lighting
- Audio
- SHIP A GAME
- Physics (Jolt)
- Input abstraction / developer console
- WebGPU renderer implementation?
