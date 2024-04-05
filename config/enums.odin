package callisto_config

import "../common"
import "core:log"

Debug_Log_Level_Flag    :: log.Level
Version                 :: common.Version

Build_Platform_Flag     :: enum {
    Desktop,
    // Android,    // Not implemented
    // IOS,        // Not implemented
    // Web,        // Not implemented
}

Renderer_Api_Flag       :: enum {
    Vulkan,
    // WebGPU,     // Not implemented
}
