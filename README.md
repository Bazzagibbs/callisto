# Callisto Engine

Desktop game engine written in [Odin](https://odin-lang.org).

[Engine documentation](https://docs.bazzagibbs.com/callisto) (WIP)
[Galileo asset format documentation](https://docs.bazzagibbs.com/galileo)

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

## Callisto Debug Utilities

Callisto provides a `util` package that can help with debugging boilerplate.

```odin
package main
include "callisto"
include "core:log"
include "callisto/util"

main :: proc() {
    
    when ODIN_DEBUG {
        context.logger = util.create_logger()
        defer util.destroy_logger(context.logger)

        // A tracking allocator that will print out any bad allocations and/or memory leaks when it is destroyed
        track := util.create_tracking_allocator()
        context.allocator = mem.tracking_allocator(&track)
        defer util.destroy_tracking_allocator(&track)
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

## In progress

- Renderer abstraction
  - Vulkan implementation
  - WebGL implementation
- Asset file format "Galileo" (.gali)

## Project Plan

- glTF/glb model support
- HDRI skybox lighting
- Profiling (Spall)
- Audio
- SHIP A GAME
- Input abstraction / developer console
- WebGPU renderer implementation?
