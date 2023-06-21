package callisto

import "core:log"
import "engine/window"
import "engine/log_util"
import "engine/renderer"
import "input"

logger: log.Logger
logger_internal: log.Logger

// Initialize Callisto engine. If successful, call `engine.shutdown()` before exiting the program.
init :: proc() -> (ok: bool) {
    ok = true

    logger, logger_internal = log_util.create()
    context.logger = logger_internal
    log.debug("Initializing Callisto engine")
    
    if ok = window.init(); ok == false {
        log.error("Window could not be initialized")
        return
    }
    defer if !ok do window.shutdown()   // Clean up if any future setup fails

    // TODO: Init input manager
    if ok = input.init(); ok == false {
        log.error("Input could not be initialized")
        return
    }
    defer if !ok do input.shutdown()

    // TODO: Init renderer
    if ok = renderer.init(); ok == false {
        log.error("Renderer could not be initialized")
        return
    }
    defer if !ok do renderer.shutdown()

    return
}


// Shut down Callisto engine, cleaning up managed internal allocations.
shutdown :: proc() {
    // The following cleanup methods are in the order in which they were initialized.
    // Deferring them executes in reverse order at the end of the procedure scope.
    
    context.logger = logger_internal
    
    defer log_util.destroy(logger, logger_internal)
    defer window.shutdown()
    defer input.shutdown()
    defer renderer.shutdown()
    
}



should_loop :: proc() -> bool {
    input.flush()
    window.poll_events()
    return window.should_close() == false
}

