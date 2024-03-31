package callisto

import "common"
import "core:log"
import "platform"
import "window"
import "graphics"
import "input"
import "debug"

// Initialize Callisto engine. If successful, call `engine.shutdown()` before exiting the program.
create :: proc(create_info: ^Engine_Create_Info) -> (engine: Engine, res: Result) {
    debug.profile_scope()
    
    log.info("Initializing Callisto engine")
   
    // PLATFORM
    platform.init()
    res = platform.init(); 
    check_result(res, "Platform") or_return
    defer if res != .Ok do platform.destroy()

    // WINDOW
    engine.window, res = window.create()
    check_result(res, "Window") or_return
    defer if res != .Ok do window.destroy(engine.window)

    // INPUT
    platform.input_bind(engine.window, &engine.input)

    // RENDERER
    engine.renderer, res = graphics.renderer_create(create_info.renderer_create_info);
    check_result(res, "Renderer") or_return;
    defer if res != .Ok do graphics.renderer_destroy(engine.renderer)

    return engine, .Ok
}
// Shut down Callisto engine, cleaning up internal allocations.
destroy :: proc(engine: ^Engine) {
    debug.profile_scope()
    
    graphics.renderer_destroy(engine.renderer)
    window.destroy(engine.window)
    platform.destroy()
}


check_result :: common.check_result
