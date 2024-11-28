package callisto

Window :: struct {
        _platform : Platform_Window,
}

Window_Init_Info :: struct {
        name     : string,
        style    : Window_Style_Flags,
        position : Maybe([2]int),
        size     : Maybe([2]int),
}

Window_Style_Flags :: bit_set[Window_Style_Flag]

Window_Style_Flag :: enum {
        Border,
        Resize_Edges,
        Menu,
        Minimize_Button,
        Maximize_Button,
}

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

// Implemented in platform_*.odin

// Platform                 :: struct
// Platform_Window          :: struct
// exit                     :: proc(exit_code: Exit_Code)
// get_exe_directory        :: proc(allocator := context.allocator) -> string
// get_persistent_directory :: proc(allocator := context.allocator) -> string
