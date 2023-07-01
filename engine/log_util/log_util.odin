package callisto_engine_log_util

import "core:log"
import "../../config"


create :: proc() -> (logger, logger_internal: log.Logger) {
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


destroy :: proc(logger, logger_internal: log.Logger) {
    log.info("Shutting down logger")
    log.destroy_console_logger(logger)
    log.destroy_console_logger(logger_internal)
}