package callisto_common

import "base:runtime"
import "core:dynlib"
import "core:os/os2"
import "core:time"
import "core:mem"
import sdl "vendor:sdl3"

Runner :: struct {
        app_data           : rawptr,
        app_dll            : Callisto_Dll,

        ctx                : runtime.Context,
        tracking_allocator : mem.Tracking_Allocator,
        dll_original_path  : string,
        dll_generation     : int,
        dll_modified       : time.Time,
}


Callisto_Dll :: struct {
        lib            : dynlib.Library,
        callisto_init  : #type proc(app_data: ^rawptr) -> sdl.AppResult,
        callisto_event : #type proc(app_data: rawptr, event: ^sdl.Event) -> sdl.AppResult,
        callisto_loop  : #type proc(app_data: rawptr) -> sdl.AppResult,
        callisto_quit  : #type proc(app_data: rawptr, result: sdl.AppResult),
}
