//+private
package callisto_engine_renderer

import "core:log"
// import "vulkan"
import "../window"

_init :: proc() -> (ok: bool) {
    log.debug("Initializing renderer: Vulkan")
    return true
}

_shutdown :: proc() {
    log.debug("Shutting down renderer")
}

