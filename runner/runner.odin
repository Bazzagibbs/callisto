package callisto_runner

import cal ".."
import "core:log"
import "core:strings"
import "core:time"
import "core:encoding/ansi"
import "core:fmt"
import "core:os/os2"
import "core:os"
import "core:io"
import "core:bytes"

HOT_RELOAD :: #config(HOT_RELOAD, false)
APP_NAME   :: cal.APP_NAME

// LOG_FILE_MAX_SIZE := 4_000_000 // 4 MB
LOG_FILE_MAX_SIZE := 4_000 // 4 MB

NO_STDOUT :: ODIN_OS == .Windows && ODIN_WINDOWS_SUBSYSTEM == "windows"

Result                     :: cal.Result
Runner                     :: cal.Runner
Dll_Symbol_Table           :: cal.Dll_Symbol_Table

Engine_Init_Info           :: cal.Engine_Init_Info

Event                      :: cal.Event

Window_Event               :: cal.Window_Event
Window_Moved               :: cal.Window_Moved
Window_Resized             :: cal.Window_Resized
Window_Opened              :: cal.Window_Opened
Window_Close_Request       :: cal.Window_Close_Request
Window_Closed              :: cal.Window_Closed
Window_Focus_Gained        :: cal.Window_Focus_Gained
Window_Focus_Lost          :: cal.Window_Focus_Lost
                            
Input_Event                :: cal.Input_Event
Input_Text                 :: cal.Input_Text
Input_Button               :: cal.Input_Button
Input_Vector1              :: cal.Input_Vector1
Input_Vector2              :: cal.Input_Vector2
Input_Vector3              :: cal.Input_Vector3

Input_Hand                 :: cal.Input_Hand
Input_Button_Source        :: cal.Input_Button_Source
Input_Button_Motion        :: cal.Input_Button_Motion
Input_Modifier             :: cal.Input_Modifier
Input_Modifiers            :: cal.Input_Modifiers
Input_Vector1_Source       :: cal.Input_Vector1_Source
Input_Vector2_Source       :: cal.Input_Vector2_Source
Input_Vector3_Source       :: cal.Input_Vector3_Source

Window                     :: cal.Window
Window_Create_Info         :: cal.Window_Create_Info
Window_Style_Flags         :: cal.Window_Style_Flags

Exit_Code                  :: cal.Exit_Code

callisto_context_init      :: cal.callisto_context_init
callisto_context_destroy   :: cal.callisto_context_destroy
callisto_logger_init       :: cal.callisto_logger_init
callisto_logger_destroy    :: cal.callisto_logger_destroy
callisto_logger_options    :: cal.callisto_logger_options
get_exe_directory          :: cal.get_exe_directory

default_runner :: proc (ctx := context) -> Runner {
        return Runner {
                ctx              = ctx,
                should_close     = false,
                platform_init    = platform_init,
                platform_destroy = platform_destroy,
                window_create    = window_create,
                window_destroy   = window_destroy,
                event_pump       = event_pump,
                logger_proc      = logger_proc,
        }
}


logger_proc :: proc(logger_data: rawptr, level: log.Level, text: string, options: log.Options, location := #caller_location) {
        data := (^cal.Callisto_Logger_Data)(logger_data)

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

        // // to file
        // if data.file_handle_a != os.INVALID_HANDLE {
        //         data.file_write_size += fmt.fprintln(data.file_handle_a, header, text, sep = "")
        // }

        // to stdout
        when !NO_STDOUT {
                if level <= log.Level.Warning {
                        fmt.println(header, text, sep = "")
                } else {
                        fmt.eprintln(header, text, sep = "")
                }
        }

        // to dev console
        if data.dev_console_writer != {} {
                _, _ = io.write_string(data.dev_console_writer, header)
                _, _ = io.write_string(data.dev_console_writer, text)
                _, _ = io.write(data.dev_console_writer, {'\n'})
        }


        // // Swap log files if they get too large
        // if data.file_write_size >= LOG_FILE_MAX_SIZE {
        //         data.file_write_size = 0
        //         log.debug("Swapping log file") // printed to the end of the full file
        //         data.file_write_size = 0
        //         data.file_handle_a, data.file_handle_b = data.file_handle_b, data.file_handle_a
        //         os.ftruncate(data.file_handle_a, 0)
        // }
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
