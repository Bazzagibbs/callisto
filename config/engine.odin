package callisto_config
import "core:log"

ENGINE_NAME                 : string                    : "Callisto"
ENGINE_VERSION              : [3]u32                    : {0, 0, 1}

RENDERER_FRAMES_IN_FLIGHT   : int                       : 2
RENDERER_API                : Renderer_Api_Flag         : .Vulkan
