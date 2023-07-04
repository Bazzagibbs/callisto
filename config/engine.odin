package callisto_config
import "core:log"

ENGINE_DEBUG: bool: true
ENGINE_DEBUG_LEVEL: log.Level: .Debug
ENGINE_NAME: string: "Callisto"
ENGINE_VERSION: [3]u32: {0, 0, 1}

RENDERER_FRAMES_IN_FLIGHT: u32: 2