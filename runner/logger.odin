package callisto_runner

import "core:fmt"
import "core:log"
import "core:os"
import "core:os/os2"
import "core:strings"
import "core:time"
import "core:encoding/ansi"
import "core:io"
import cal ".."


logger_multi_proc :: proc(logger_data: rawptr, level: log.Level, text: string, options: log.Options, location := #caller_location) {
        data := (^cal.Callisto_Logger_Data)(logger_data)

        if data.file_a != nil {
                file_opts := options - {.Terminal_Color}
                data.file_write_size += logger_file(data.file_a, level, text, file_opts, location)
                if data.file_write_size >= LOG_FILE_MAX_SIZE {
                        logger_rotate_files(data)
                }
        }
        
        when !NO_STDOUT {
                stdf := os2.stdout if level < .Error else os2.stderr
                _ = logger_file(stdf, level, text, options, location)
        }

        if data.dev_console_writer != {} {
                logger_io_writer(data.dev_console_writer, level, text, options, location)
        }
}


logger_io_writer :: proc(writer: io.Writer, level: log.Level, text: string, options: log.Options, location := #caller_location) {
        backing: [1024]byte
        sb := strings.builder_from_bytes(backing[:])

        do_level_header(options, &sb, level)

        when time.IS_SUPPORTED {
                do_time_header(options, &sb, time.now())
        }

        do_location_header(options, &sb, location)
        
        if .Thread_Id in options {
                fmt.sbprintf(&sb, "(t:{}) ", os.current_thread_id())
        }

        header := strings.to_string(sb)
        _, _ = io.write_string(writer, header)
        _, _ = io.write_string(writer, text)
        _, _ = io.write(writer, {'\n'})
}


logger_file :: proc(file: ^os2.File, level: log.Level, text: string, options: log.Options, location := #caller_location) -> (written: int){
        backing: [1024]byte
        sb := strings.builder_from_bytes(backing[:])

        do_level_header(options, &sb, level)

        when time.IS_SUPPORTED {
                do_time_header(options, &sb, time.now())
        }

        do_location_header(options, &sb, location)
        
        if .Thread_Id in options {
                fmt.sbprintf(&sb, "(t:{}) ", os.current_thread_id())
        }

        header := strings.to_string(sb)

        written, _ = os2.write_strings(file, header, text, "\n")
        return
}


Level_Header :: struct {
        label : string,
        color : string,
}

Level_Headers := #sparse [log.Level]Level_Header {
        .Debug   = {"[Debug] ", ansi.CSI + ansi.FG_BRIGHT_BLACK + ansi.SGR},
        .Info    = {"[Info ] ", ansi.CSI + ansi.RESET + ansi.SGR},
        .Warning = {"[Warn ] ", ansi.CSI + ansi.FG_YELLOW + ansi.SGR},
        .Error   = {"[ERROR] ", ansi.CSI + ansi.FG_RED + ansi.SGR},
        .Fatal   = {"[FATAL] ", ansi.CSI + ansi.FG_RED + ansi.SGR},
}


do_level_header :: proc(opts: log.Options, sb: ^strings.Builder, level: log.Level) {
        RESET :: ansi.CSI + ansi.RESET + ansi.SGR

        if .Level in opts {
                header := Level_Headers[level]
                if .Terminal_Color in opts {
                        fmt.sbprintf(sb, header.color)
                }
                fmt.sbprintf(sb, header.label)
                if .Terminal_Color in opts {
                        fmt.sbprintf(sb, RESET)
                }
        }
}

do_time_header :: log.do_time_header

do_location_header :: log.do_location_header

logger_rotate_files :: proc (data: ^cal.Callisto_Logger_Data) {
        data.file_write_size = 0
        log.info("--- Swapping Log files ---")
        data.file_write_size = 0

        file_temp := data.file_a
        data.file_a = data.file_b
        data.file_b = file_temp

        os2.truncate(data.file_a, 0)
        os2.seek(data.file_a, 0, .Start)
}
