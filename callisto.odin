package callisto

import "core:log"
import "window"
import "graphics"
import "input"
import "debug"

// Initialize Callisto engine. If successful, call `engine.shutdown()` before exiting the program.
init :: proc() -> (ok: bool) {
    debug.profile_scope()
    
    log.info("Initializing Callisto engine")

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

    // ok = graphics.init(); if ok == false {
    //     log.fatal("Renderer could not be initialized")
    //     return
    // }
    // defer if !ok do graphics.shutdown()

    return
}


// Shut down Callisto engine, cleaning up internal allocations.
shutdown :: proc() {
    debug.profile_scope()
    // The following cleanup methods are in the order in which they were initialized.
    // Deferring them executes in reverse order at the end of the procedure scope.
    
    defer window.shutdown()
    defer input.shutdown()
    // defer graphics.shutdown()
}



should_loop :: proc() -> bool {
    input.flush()
    window.poll_events()
    if window.should_close() == false {
        return true
    }

    // graphics.wait_until_idle() // Wait until renderer resources are not in use before starting shutdown
    return false
}

