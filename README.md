# Callisto Engine

A game engine written in Odin.

## Creating an application

Add the engine somewhere to your project and include it in your app. This example will assume the package is a direct child of your root directory, `project-root-dir/callisto/`

1. Initialize the engine
2. Perform your application code
3. Shutdown the engine

```odin
package main

include "callisto/engine"

main :: proc() {
  engine.init()
  defer engine.shutdown()

  
  // gameplay code here
}
```

## Project Plan

- Window (abstraction)
- Basic input forwarding
- Logical layers
- Game loop
- Renderer abstraction
  - OpenGL/WebGL
  - Vulkan or DX12 later
- Input abstraction / dev console
- Audio