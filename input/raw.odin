package callisto_input

import "../common"
import "../debug"
import "../window"
import "../platform"

create :: proc() -> (input: ^Input, result: common.Result) {
    return new(Input), .Ok
}

destroy :: proc(input: ^Input) {
    free(input)
}

// Set up/down state buffers and axis accumulators to zero.
flush :: proc(input: ^Input) {
    input.kbm_down_buffer = {}
    input.kbm_up_buffer = {}
    input.scroll_delta = {}
    input.mouse_pos_last = input.mouse_pos
}

// Set the cursor lock mode and visibility. See `Cursor_Lock_Mode` for more details.
set_cursor_lock :: window.set_cursor_lock

// Set whether mouse input data should skip acceleration curve processing or not.
set_mouse_input_raw :: window.set_mouse_input_raw

// Returns true if the specified key is pressed this frame, and was not pressed last frame.
get_key_down :: proc(input: ^Input, key: Key_Code) -> bool {
    return bool(input.kbm_down_buffer.keys[int(key)])
}

// Returns true if the specified key is not pressed this frame, and was pressed last frame.
get_key_up :: proc(input: ^Input, key: Key_Code) -> bool {
    return bool(input.kbm_up_buffer.keys[int(key)])
}

// Returns true if the specified key is pressed this frame.
get_key :: proc(input: ^Input, key: Key_Code) -> bool {
    return bool(input.kbm_pressed_buffer.keys[int(key)])
}

// Returns true if the specified mouse button is pressed this frame, and was not pressed last frame.
get_mouse_button_down :: proc(input: ^Input, button: Mouse_Button) -> bool {
    return button in input.kbm_down_buffer.mouse_buttons
}

// Returns true if the specified mouse button is not pressed this frame, and was pressed last frame.
get_mouse_button_up :: proc(input: ^Input, button: Mouse_Button) -> bool {
    return button in input.kbm_up_buffer.mouse_buttons
}

// Returns true if the specified mouse button is pressed this frame.
get_mouse_button :: proc(input: ^Input, button: Mouse_Button) -> bool {
    return button in input.kbm_pressed_buffer.mouse_buttons
}

// Returns the mouse position in screen coordinates relative to the top-left of the window. Right is x+, down is y+.
get_mouse_position :: proc(input: ^Input) -> (mouse_pos: [2]f32) {
    return {f32(input.mouse_pos.x), f32(input.mouse_pos.y)}
}

// Returns the mouse position in screen coordinates relative to the top-left of the window. Right is x+, down is y+.
get_mouse_position_f64 :: proc(input: ^Input) -> (mouse_pos: [2]f64) {
    return input.mouse_pos
}

// Returns the delta position of the mouse in screen coordinates relative to the top-left of the window. Right is x+, down is y+.
get_mouse_delta :: proc(input: ^Input) -> (mouse_delta: [2]f32) {
    temp := input.mouse_pos - input.mouse_pos_last
    return {f32(temp.x), f32(temp.y)}
}

// Returns the delta position of the mouse in screen coordinates relative to the top-left of the window. Right is x+, down is y+.
get_mouse_delta_f64 :: proc(input: ^Input) -> (mouse_delta: [2]f64) {
    return input.mouse_pos - input.mouse_pos_last
}

// Returns the delta position of the mouse scroll wheel, in number of "steps" on a regular scroll wheel.
get_scroll_delta :: proc(input: ^Input) -> (scroll_delta: [2]f32) {
    return {f32(input.scroll_delta.x), f32(input.scroll_delta.y)}
}

// Returns the delta position of the mouse scroll wheel, in number of "steps" on a regular scroll wheel.
get_scroll_delta_f64 :: proc(input: ^Input) -> (scroll_delta: [2]f64) {
    return input.scroll_delta
}
