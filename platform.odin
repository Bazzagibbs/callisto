package callisto

import "core:strings"
import "core:bytes"
import "core:path/filepath"


Window_Style_Flags_DEFAULT :: Window_Style_Flags {.Border, .Resize_Edges, .Menu, .Maximize_Button, .Minimize_Button}

window_init :: proc(e: ^Engine, w: ^Window, init_info: ^Window_Init_Info, location := #caller_location) -> (res: Result) {
        // validate_info()
        return e.runner->window_init(w, init_info)
}

window_destroy :: proc(e: ^Engine, window: ^Window) {
        e.runner->window_destroy(window)
        window^ = {}
}


// Pumps all events in the event queue, then returns.
// Only required if engine was initialized with `event_behaviour = .Manual`
event_pump :: proc(e: ^Engine) {
        e.runner->event_pump()
}


// On reload this will be reacquired.
@(private) 
_exe_dir_buffer : [4096]byte // Linux length, windows is ~256
@(private)
_exe_dir : string

get_asset_path :: proc(filename: string, allocator := context.allocator) -> string {
        if _exe_dir == {} {
                sb := strings.builder_from_bytes(_exe_dir_buffer[:])
                strings.write_string(&sb, get_exe_directory(context.temp_allocator))
                _exe_dir = strings.to_string(sb)
        }
        
        return filepath.join({_exe_dir, "data/assets", filename}, allocator)
}


// Implemented in platform_*.odin

// exit                     :: proc(exit_code: Exit_Code)
// get_exe_directory        :: proc(allocator := context.allocator) -> string
// get_persistent_directory :: proc(allocator := context.allocator) -> string
