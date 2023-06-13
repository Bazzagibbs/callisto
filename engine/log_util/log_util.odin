package callisto_engine_logger

import "core:log"


create :: proc() -> (logger, logger_internal: log.Logger) {
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
    return
}


destroy :: proc(logger, logger_internal: log.Logger) {
    log.info("Shutting down logger")
    log.destroy_console_logger(logger)
    log.destroy_console_logger(logger_internal)
}