//+build windows, linux, darwin
//+private
package callisto_input

// TO BE IMPLEMENTED:
// Gamepad bindings
// Text callback handling


import "core:log"
import "core:c"
import "vendor:glfw"
import "../engine/window"

_init :: proc() -> (ok: bool) {
    log.debug("Initializing input: GLFW")

    // Set up callbacks to glfw window
    // Keyboard
    glfw.SetKeyCallback(_handle(), glfw.KeyProc(_key_callback))
    glfw.SetCharCallback(_handle(), glfw.CharProc(_char_callback))
    // Mouse
    glfw.SetCursorPosCallback(_handle(), glfw.CursorPosProc(_cursor_position_callback))
    glfw.SetCursorEnterCallback(_handle(), glfw.CursorEnterProc(_cursor_enter_callback))
    glfw.SetMouseButtonCallback(_handle(), glfw.MouseButtonProc(_mouse_button_callback))
    glfw.SetScrollCallback(_handle(), glfw.ScrollProc(_scroll_callback))
    // Joystick

    return true
}

_shutdown :: proc() {
    log.debug("Shutting down input")
    
}

_handle :: #force_inline proc() -> glfw.WindowHandle {
    return glfw.WindowHandle(window.handle)
}

_set_cursor_lock :: proc(mode: Cursor_Lock_Mode) {
    glfw.SetInputMode(_handle(), glfw.CURSOR, c.int(mode))
}

_set_mouse_input_raw :: proc(use_raw: bool = true) {
    glfw.SetInputMode(_handle(), glfw.RAW_MOUSE_MOTION, c.int(use_raw))
}


// GLFW-specific callbacks
_key_callback :: proc(window: glfw.WindowHandle, key, scancode, action, mods: c.int){
    using input_accumulator
    switch Button_Press_Action(action) {
        case .Press:
            kbm_down_buffer.keys[key] = true
            kbm_pressed_buffer.keys[key] = true
    
        case .Release:
            kbm_up_buffer.keys[key] = true
            kbm_pressed_buffer.keys[key] = false

        case .Repeat:
    }
}

_char_callback :: proc(window: glfw.WindowHandle, key, scancode, action, mods: c.int){

}

_cursor_position_callback :: proc(window: glfw.WindowHandle, x_pos, y_pos: c.double){
    input_accumulator.mouse_pos = {x_pos, y_pos}
}

_cursor_enter_callback :: proc(window: glfw.WindowHandle, entered: c.int) {

}

_mouse_button_callback :: proc(window: glfw.WindowHandle, button, action, mods: c.int) {
    using input_accumulator
    switch Button_Press_Action(action) {
        case .Press:
            kbm_down_buffer.mouse_buttons += {Mouse_Button(button)}
            kbm_pressed_buffer.mouse_buttons += {Mouse_Button(button)}
        case .Release:
            kbm_up_buffer.mouse_buttons += {Mouse_Button(button)}
            kbm_pressed_buffer.mouse_buttons -= {Mouse_Button(button)}
        case .Repeat:
    }
}

_scroll_callback :: proc(window: glfw.WindowHandle, x_offset, y_offset: c.double) {
    // Treat scroll as axis
    input_accumulator.scroll_delta += {x_offset, y_offset}

    // Treat scroll as buttons
    if y_offset < -Scroll_Wheel_Step_Threshold {
        input_accumulator.kbm_down_buffer.mouse_buttons += {.Wheel_Down}
        input_accumulator.kbm_up_buffer.mouse_buttons += {.Wheel_Down}
        input_accumulator.kbm_pressed_buffer.mouse_buttons += {.Wheel_Down}
    }
    if y_offset > Scroll_Wheel_Step_Threshold {
        input_accumulator.kbm_down_buffer.mouse_buttons += {.Wheel_Up}
        input_accumulator.kbm_up_buffer.mouse_buttons += {.Wheel_Up}
        input_accumulator.kbm_pressed_buffer.mouse_buttons += {.Wheel_Up}
    }
}