package callisto_input

import "../debug"

input_accumulator := Input_Accumulator{}
Scroll_Wheel_Step_Threshold :: 0.1

KBM_State :: struct {
    keys: [349]b8,
    mouse_buttons: bit_set[Mouse_Button],
}

Input_Accumulator :: struct {
    kbm_down_buffer:        KBM_State,
    kbm_up_buffer:          KBM_State,
    kbm_pressed_buffer:     KBM_State,
    mouse_pos:              [2]f64,
    mouse_pos_last:         [2]f64,
    scroll_delta:           [2]f64,
}


init :: proc() -> (ok: bool) {
    debug.profile_scope()
    return _init()
}

shutdown:: proc() {
    debug.profile_scope()
    _shutdown()
}

// Set up/down state buffers and axis accumulators to zero.
flush :: proc() {
    input_accumulator.kbm_down_buffer = {}
    input_accumulator.kbm_up_buffer = {}
    input_accumulator.scroll_delta = {}
    input_accumulator.mouse_pos_last = input_accumulator.mouse_pos
}

// Set the cursor lock mode and visibility. See `Cursor_Lock_Mode` for more details.
set_cursor_lock :: proc(mode: Cursor_Lock_Mode) {
    _set_cursor_lock(mode)
}

// Set whether mouse input data should skip acceleration curve processing or not.
set_mouse_input_raw :: proc(use_raw: bool) {
    _set_mouse_input_raw(use_raw)
}

// Returns true if the specified key is pressed this frame, and was not pressed last frame.
get_key_down :: proc(key: Key_Code) -> bool {
    return bool(input_accumulator.kbm_down_buffer.keys[int(key)])
}

// Returns true if the specified key is not pressed this frame, and was pressed last frame.
get_key_up :: proc(key: Key_Code) -> bool {
    return bool(input_accumulator.kbm_up_buffer.keys[int(key)])
}

// Returns true if the specified key is pressed this frame.
get_key :: proc(key: Key_Code) -> bool {
    return bool(input_accumulator.kbm_pressed_buffer.keys[int(key)])
}

// Returns true if the specified mouse button is pressed this frame, and was not pressed last frame.
get_mouse_button_down :: proc(button: Mouse_Button) -> bool {
    return button in input_accumulator.kbm_down_buffer.mouse_buttons
}

// Returns true if the specified mouse button is not pressed this frame, and was pressed last frame.
get_mouse_button_up :: proc(button: Mouse_Button) -> bool {
    return button in input_accumulator.kbm_up_buffer.mouse_buttons
}

// Returns true if the specified mouse button is pressed this frame.
get_mouse_button :: proc(button: Mouse_Button) -> bool {
    return button in input_accumulator.kbm_pressed_buffer.mouse_buttons
}

// Returns the mouse position in screen coordinates relative to the top-left of the window. Right is x+, down is y+.
get_mouse_position :: proc() -> (mouse_pos: [2]f32) {
    return {f32(input_accumulator.mouse_pos.x), f32(input_accumulator.mouse_pos.y)}
}

// Returns the mouse position in screen coordinates relative to the top-left of the window. Right is x+, down is y+.
get_mouse_position_f64 :: proc() -> (mouse_pos: [2]f64) {
    return input_accumulator.mouse_pos
}

// Returns the delta position of the mouse in screen coordinates relative to the top-left of the window. Right is x+, down is y+.
get_mouse_delta :: proc() -> (mouse_delta: [2]f32) {
    temp := input_accumulator.mouse_pos - input_accumulator.mouse_pos_last
    return {f32(temp.x), f32(temp.y)}
}

// Returns the delta position of the mouse in screen coordinates relative to the top-left of the window. Right is x+, down is y+.
get_mouse_delta_f64 :: proc() -> (mouse_delta: [2]f64) {
    return input_accumulator.mouse_pos - input_accumulator.mouse_pos_last
}

// Returns the delta position of the mouse scroll wheel, in number of "steps" on a regular scroll wheel.
get_scroll_delta :: proc() -> (scroll_delta: [2]f32) {
    return {f32(input_accumulator.scroll_delta.x), f32(input_accumulator.scroll_delta.y)}
}

// Returns the delta position of the mouse scroll wheel, in number of "steps" on a regular scroll wheel.
get_scroll_delta_f64 :: proc() -> (scroll_delta: [2]f64) {
    return input_accumulator.scroll_delta
}
