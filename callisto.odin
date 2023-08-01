package callisto

import "core:log"
import "window"
import "graphics"
import "input"

logger: log.Logger
logger_internal: log.Logger

// Initialize Callisto engine. If successful, call `engine.shutdown()` before exiting the program.
init :: proc() -> (ok: bool) {

    logger, logger_internal = create_loggers()
    context.logger = logger_internal
    log.info("Initializing Callisto engine")
    defer if !ok do destroy_loggers(logger, logger_internal)

    ok = window.init(); if ok == false {
        log.fatal("Window could not be initialized")
        return
    }
    defer if !ok do window.shutdown()

    ok = input.init(); if ok == false {
        log.fatal("Input could not be initialized")
        return
    }
    defer if !ok do input.shutdown()

    ok = graphics.init(); if ok == false {
        log.fatal("Renderer could not be initialized")
        return
    }
    defer if !ok do graphics.shutdown()

    return
}


// Shut down Callisto engine, cleaning up internal allocations.
shutdown :: proc() {
    // The following cleanup methods are in the order in which they were initialized.
    // Deferring them executes in reverse order at the end of the procedure scope.
    
    context.logger = logger_internal
    
    defer destroy_loggers(logger, logger_internal)
    defer window.shutdown()
    defer input.shutdown()
    defer graphics.shutdown()
    
}



should_loop :: proc() -> bool {
    input.flush()
    window.poll_events()
    return window.should_close() == false
}

