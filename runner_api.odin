package callisto
import "base:runtime"
import "core:os"
import "core:dynlib"

Runner :: struct {
        ctx                      : runtime.Context,
        app_data                 : rawptr,
        should_close             : bool,

        symbols                  : Dll_Symbol_Table,
        last_modified            : os.File_Time,
        version                  : int,

        _platform                : Platform,

        platform_init            : #type proc (runner: ^Runner, init_info: ^Engine_Init_Info) -> Result,
        platform_destroy         : #type proc (runner: ^Runner),
        window_create            : #type proc (runner: ^Runner, create_info: ^Window_Create_Info, out_window: ^Window) -> Result,
        window_destroy           : #type proc (runner: ^Runner, window: ^Window),
}

Dll_Symbol_Table :: struct {
        lib              : dynlib.Library,
        callisto_init    : #type proc (runner: ^Runner) -> (app_data: rawptr),
        callisto_destroy : #type proc (app_data: rawptr),
        callisto_event   : #type proc (event: Event, app_data: rawptr),
        callisto_loop    : #type proc (app_data: rawptr),
}
