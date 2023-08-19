package callisto_config

import "core:log"

Engine_Debug_Level_Flag :: log.Level

Build_Target_Flag :: enum {
    Desktop,
    Android,    // Not implemented
    IOS,        // Not implemented
    Web,        // Not implemented
}

Renderer_Api_Flag :: enum {
    Vulkan,
    WebGPU,     // Not implemented
}
