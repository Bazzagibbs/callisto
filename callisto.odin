package callisto

import "core:log"
import "platform"
import "window"
import "graphics"
import "input"
import "debug"

bound_ctx: ^Engine_Context

// Initialize Callisto engine. If successful, call `engine.shutdown()` before exiting the program.
init :: proc(engine_ctx: ^Engine_Context) -> (ok: bool) {
    debug.profile_scope()
    
    log.info("Initializing Callisto engine")
    
    ok = platform.init(); if !ok {
        log.fatal("Platform could not be initialized")
        return false
    }
    defer if !ok do platform.shutdown()

    ok = window.init(&engine_ctx.window); if !ok {
        log.fatal("Window could not be initialized")
        return false
    }
    defer if !ok do window.shutdown(&engine_ctx.window)

    platform.set_input_sink(&engine_ctx.window, &engine_ctx.input)

    ok = graphics.init(&engine_ctx.graphics); if !ok {
        log.fatal("Renderer could not be initialized")
        return false
    }
    defer if !ok do graphics.shutdown(&engine_ctx.graphics)

    bind_context(engine_ctx)

    return
}
// Shut down Callisto engine, cleaning up internal allocations.
shutdown :: proc(engine_ctx: ^Engine_Context) {
    debug.profile_scope()
    
    graphics.shutdown(&engine_ctx.graphics)
    window.shutdown(&engine_ctx.window)
}



should_loop :: proc() -> bool {
    input.flush()
    platform.poll_events()
    if window.should_close() == false {
        return true
    }

    // graphics.wait_until_idle() // Wait until renderer resources are not in use before starting shutdown
    return false
}

bind_context :: proc(engine_ctx: ^Engine_Context) {
    window.bind_context(&engine_ctx.window)
    input.bind_context(&engine_ctx.input)
    graphics.bind_context(&engine_ctx.graphics)
}
