package callisto

import "core:log"
import "engine/window"
import "engine/log_util"

logger: log.Logger
logger_internal: log.Logger


// Initialize Callisto engine. Call `engine.shutdown()` before exiting the program.
init :: proc() -> (ok: bool) {
    ok = true

    logger, logger_internal = log_util.create()
    context.logger = logger_internal
    log.info("Initializing Callisto engine")
    
    if ok1 := window.init(); !ok1 {
        ok = false
        return
    }
    defer if !ok do window.shutdown()   // Clean up if any future setup fails

    // TODO: Init input manager
    // TODO: Init renderer

    return
}

should_loop :: proc() -> bool {
    if window.should_close() {        
        return false
    }

    window.poll_events()
    return true
}


// Shut down Callisto engine, cleaning up managed internal allocations.
shutdown :: proc() {
    context.logger = logger_internal

    // The following cleanup methods are in the order in which they were initialized.
    // Deferring them executes in reverse order at the end of the procedure scope.
    defer log_util.destroy(logger, logger_internal)
    defer window.shutdown()
    
}



