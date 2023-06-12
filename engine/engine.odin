package callisto_engine

import "core:log"

logger, logger_internal: log.Logger

// Initialize Callisto engine. Call `engine.shutdown()` before exiting the program.
init :: proc() -> bool {
    init_logger()
    context.logger = logger_internal
    log.debug("Initializing Callisto engine")
    return true
}


// Shut down Callisto engine, cleaning up managed internal allocations.
shutdown :: proc() {
    context.logger = logger_internal

    log.info("Shutting down logger")
    shutdown_logger()
}



@private
init_logger :: proc() {
    console_logger_opts: bit_set[log.Option]: log.Options {
        .Level, 
        .Terminal_Color, 
        .Short_File_Path,
        .Procedure, 
        .Line, 
        .Time,
    }

    logger = log.create_console_logger(opt=console_logger_opts)
    logger_internal = log.create_console_logger(opt=console_logger_opts, ident="CAL")
}


@private
shutdown_logger :: proc() {
    log.destroy_console_logger(logger)
    log.destroy_console_logger(logger_internal)
}