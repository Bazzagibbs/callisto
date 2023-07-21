package callisto

import "core:log"
import "config"


create_loggers :: proc() -> (logger, logger_internal: log.Logger) {
    console_logger_opts: log.Options :{
        .Level, 
        .Terminal_Color, 
        .Short_File_Path,
        .Procedure, 
        .Line, 
        .Time,
    }

    logger = log.create_console_logger(lowest=config.ENGINE_DEBUG_LEVEL, opt=console_logger_opts)
    logger_internal = log.create_console_logger(lowest=config.ENGINE_DEBUG_LEVEL, opt=console_logger_opts, ident="CAL")
    return
}


destroy_loggers :: proc(logger, logger_internal: log.Logger) {
    log.info("Shutting down logger")
    log.destroy_console_logger(logger)
    log.destroy_console_logger(logger_internal)
}