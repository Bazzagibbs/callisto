package callisto_config
import "core:log"
import "../common"

ENGINE_NAME                     : string                : "Callisto"
ENGINE_VERSION                  : common.Version        : {0, 0, 1}

RENDERER_FRAMES_IN_FLIGHT       : int                   : 2
RENDERER_API                    : Renderer_Api_Flag     : .Vulkan
RENDERER_HEADLESS               : bool                  : false
