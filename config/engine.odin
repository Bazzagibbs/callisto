package callisto_config
import "core:log"

ENGINE_DEBUG                : bool                      : true
ENGINE_DEBUG_LEVEL          : Engine_Debug_Level_Flag   : .Debug
ENGINE_NAME                 : string                    : "Callisto"
ENGINE_VERSION              : [3]u32                    : {0, 0, 1}

RENDERER_FRAMES_IN_FLIGHT   : int                       : 2
RENDERER_API                : Renderer_Api_Flag         : .Vulkan
RENDERER_PANIC_ON_ERROR     : bool                      : true
