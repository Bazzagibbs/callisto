package callisto


window_style_default :: #force_inline proc "contextless" () -> Window_Style_Flags {
        return {.Border, .Resize_Edges, .Menu, .Maximize_Button, .Minimize_Button}
}

window_init :: proc(e: ^Engine, w: ^Window, init_info: ^Window_Init_Info) -> (res: Result) {
        validate_info(init_info)
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

// Implemented in platform_*.odin

// exit                     :: proc(exit_code: Exit_Code)
// get_exe_directory        :: proc(allocator := context.allocator) -> string
// get_persistent_directory :: proc(allocator := context.allocator) -> string
