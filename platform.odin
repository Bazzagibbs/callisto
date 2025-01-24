package callisto

import "core:strings"
import "core:bytes"
import "core:path/filepath"


window_create :: proc(e: ^Engine, create_info: ^Window_Create_Info, location := #caller_location) -> (window: Window, res: Result) {
        return e.runner->window_create(create_info)
}

window_destroy :: proc(e: ^Engine, window: ^Window) {
        e.runner->window_destroy(window)
}


// Pumps all events in the event queue, then returns.
// Only required if engine was initialized with `event_behaviour = .Manual`
event_pump :: proc(e: ^Engine) {
        e.runner->event_pump()
}


// Implemented in platform_*.odin

exit :: proc(exit_code: Exit_Code) {
        _exit(exit_code)
}


// exit                     :: proc(exit_code: Exit_Code)
// get_exe_directory        :: proc(allocator := context.allocator) -> string
// get_persistent_directory :: proc(allocator := context.allocator) -> string
