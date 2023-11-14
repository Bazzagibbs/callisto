package callisto_debug

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

    logger := log.create_console_logger(lowest=config.DEBUG_LOG_LEVEL, opt=console_logger_opts)
    return logger
}

destroy_logger :: proc(logger: log.Logger) {
    log.destroy_console_logger(logger)
}
