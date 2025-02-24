package callisto_common
import "base:runtime"
import "core:os"
import "core:dynlib"
import "core:log"
import "../config"
import "../common"

Runner :: struct {
        ctx                      : runtime.Context,
        app_memory               : rawptr,
        profiler                 : common.Profiler,
        _impl                    : _Runner_Data_Impl, // Platform-specific data

        // Events/Input
        event_behaviour          : Event_Behaviour,
        should_close             : bool,
        exit_code                : Exit_Code,
        scroll_accumulator       : [2]f32,

        // Application DLL
        symbols                  : Dll_Symbol_Table,
        last_modified            : os.File_Time,
        version                  : int,

        // Executable-owned callbacks
        // These might not even need to cross the Runner boundary? 
        // Maybe they should though, so we can have a "virtual runner" in the editor.
        platform_init            : #type proc (runner: ^Runner, create_info: ^Engine_Create_Info) -> Result,
        platform_destroy         : #type proc (runner: ^Runner),
        window_create            : #type proc (runner: ^Runner, create_info: ^Window_Create_Info) -> (Window, Result),
        window_destroy           : #type proc (runner: ^Runner, window: ^Window),
        event_pump               : #type proc (runner: ^Runner),
        logger_proc              : #type proc (logger_data: rawptr, level: log.Level, text: string, options: log.Options, location := #caller_location),
}


Dll_Symbol_Table :: struct {
        lib              : dynlib.Library,
        callisto_init    : #type proc (runner: ^Runner),
        callisto_destroy : #type proc (app_memory: rawptr),
        callisto_event   : #type proc (app_memory: rawptr, event: Event) -> (handled: bool),
        callisto_loop    : #type proc (app_memory: rawptr),
}

Exit_Code :: enum {
        Ok = 0,
        Error = 1,
}
