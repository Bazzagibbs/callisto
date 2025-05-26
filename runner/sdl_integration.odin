package callisto_runner

import sdl "vendor:sdl3"
import "core:log"
import "core:strings"
import "core:fmt"


logger_sdl_create :: proc(lowest := log.Level.Debug, opt := log.Default_Console_Logger_Opts, ident := "", allocator := context.allocator) -> log.Logger {
        return log.Logger {
                procedure    = logger_sdl_proc,
                data         = nil,
                lowest_level = lowest,
                options      = opt,
        }
}


logger_sdl_destroy :: proc(logger: log.Logger) {
        // nothing to clean up yet
}


// Forward "core:log" calls to SDL's abstraction - might be useful for weird platforms.
logger_sdl_proc :: proc(logger_data: rawptr, level: log.Level, text: string, options: log.Options, location := #caller_location) {
	
        backing: [1024]byte //NOTE(Hoej): 1024 might be too much for a header backing, unless somebody has really long paths.
	buf := strings.builder_from_bytes(backing[:])

        fmt.sbprint(&buf, text)

        text_cstr, _ := strings.to_cstring(&buf)
        backing[len(backing) - 1] = 0 // in case the string builder overflowed the buffer

        category := i32(sdl.LogCategory.APPLICATION)
        switch level {
        case .Debug:
                sdl.LogDebug(category, text_cstr)
        case .Info:
                sdl.LogInfo(category, text_cstr)
        case .Warning:
                sdl.LogWarn(category, text_cstr)
        case .Error:
                sdl.LogError(category, text_cstr)
        case .Fatal:
                sdl.LogCritical(category, text_cstr)
        }
}
