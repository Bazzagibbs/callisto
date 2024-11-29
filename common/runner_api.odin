package callisto_common
import "base:runtime"
import "core:os"
import "core:dynlib"
import "core:log"
import "../config"

import vk "../vendor_mod/vulkan"

Runner :: struct {
        ctx                      : runtime.Context,
        app_memory               : rawptr,
        scroll_accumulator       : [2]f32,

        event_behaviour          : Event_Behaviour,
        should_close             : bool,
        exit_code                : Exit_Code ,

        symbols                  : Dll_Symbol_Table,
        last_modified            : os.File_Time,
        version                  : int,

        _platform                : Platform,

        platform_init            : #type proc (runner: ^Runner, init_info: ^Engine_Init_Info) -> Result,
        platform_destroy         : #type proc (runner: ^Runner),
        window_init              : #type proc (runner: ^Runner, window: ^Window, init_info: ^Window_Init_Info) -> Result,
        window_destroy           : #type proc (runner: ^Runner, window: ^Window),
        event_pump               : #type proc (runner: ^Runner),
        logger_proc              : #type proc (logger_data: rawptr, level: log.Level, text: string, options: log.Options, location := #caller_location),
        rhi_logger_proc          : Proc_RHI_Logger,
}

when config.RHI == "vulkan" {
        Proc_RHI_Logger :: vk.ProcDebugUtilsMessengerCallbackEXT
}

Dll_Symbol_Table :: struct {
        lib              : dynlib.Library,
        callisto_init    : #type proc (runner: ^Runner),
        callisto_destroy : #type proc (app_memory: rawptr),
        callisto_event   : #type proc (event: Event, app_memory: rawptr) -> (handled: bool),
        callisto_loop    : #type proc (app_memory: rawptr),
}

Exit_Code :: enum {
        Ok = 0,
        Error = 1,
}
