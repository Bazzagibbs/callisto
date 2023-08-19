package callisto_util

import "core:log"
import "../config"

create_logger :: proc() -> log.Logger {
    console_logger_opts: log.Options :{
        .Level, 
        .Terminal_Color, 
        .Short_File_Path,
        .Procedure, 
        .Line, 
        .Time,
    }

    logger := log.create_console_logger(lowest=config.ENGINE_DEBUG_LEVEL, opt=console_logger_opts)
    return logger
}

destroy_logger :: proc(logger: log.Logger) {
    log.destroy_console_logger(logger)
}