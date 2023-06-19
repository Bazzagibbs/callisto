package callisto_input_raw

import "core:log"
import "core:fmt"
import "core:c"
import "vendor:glfw"
import "../engine/window"

init :: proc() -> (ok: bool) {
    log.info("Initializing input backend: GLFW")

    // Set up callbacks to glfw window
    // Keyboard
    glfw.SetKeyCallback(window.handle, glfw.KeyProc(key_callback))
    glfw.SetCharCallback(window.handle, glfw.CharProc(char_callback))
    // Mouse
    glfw.SetCursorPosCallback(window.handle, glfw.CursorPosProc(cursor_position_callback))
    glfw.SetCursorEnterCallback(window.handle, glfw.CursorEnterProc(cursor_enter_callback))
    glfw.SetMouseButtonCallback(window.handle, glfw.MouseButtonProc(mouse_button_callback))
    glfw.SetScrollCallback(window.handle, glfw.ScrollProc(scroll_callback))
    // Joystick
    
    return true
}

shutdown :: proc() {
    log.info("Shutting down input")
    
}


get_mouse_pos :: proc() -> (x, y: f64) {
    return glfw.GetCursorPos(window.handle)
}


set_cursor_lock :: proc(mode: Cursor_Lock_Mode) {
    glfw_mode := cursor_lock_mode_callisto_to_glfw(mode)
    glfw.SetInputMode(window.handle, glfw.CURSOR, glfw_mode)
}

set_mouse_input_raw :: proc(use_raw: bool = true) {
    glfw.SetInputMode(window.handle, glfw.RAW_MOUSE_MOTION, c.int(use_raw))
}


get_connected_joysticks :: proc() -> (joysticks_present: [16]bool) {
    for i in 0..<16 {
        joysticks_present[i] = bool(glfw.JoystickPresent(i32(i)))
    }
    return
}

get_connected_gamepads :: proc() -> (gamepads_present: [16]bool) {
    gamepads_present = get_connected_joysticks()
    for i in 0..<16 {
        gamepads_present[i] &= bool(glfw.JoystickIsGamepad(i32(i)))
    }
    return
}



// GLFW-specific callbacks
@(private)
key_callback :: proc(window: glfw.WindowHandle, key, scancode, action, mods: c.int){
    fmt.printf("Key: %s, Down: %b\n", key_code_glfw_to_callisto(key), action)
}

@(private)
char_callback :: proc(window: glfw.WindowHandle, key, scancode, action, mods: c.int){

}

@(private)
cursor_position_callback :: proc(window: glfw.WindowHandle, x_pos, y_pos: c.double){

}

@(private)
cursor_enter_callback :: proc(window: glfw.WindowHandle, entered: c.int) {

}

@(private)
mouse_button_callback :: proc(window: glfw.WindowHandle, button, action, mods: c.int) {

}

@(private)
scroll_callback :: proc(window: glfw.WindowHandle, x_offset, y_offset: c.double) {

}

// Platform Translations

@(private)
key_code_glfw_to_callisto :: proc(glfw_mode: c.int) -> (callisto_mode: Key_Code) {
    return Key_Code(glfw_mode)
}

@(private)
key_code_callisto_to_glfw :: proc(callisto_mode: Key_Code) -> (glfw_mode: c.int) {
    return c.int(callisto_mode)
}


@(private)
cursor_lock_mode_glfw_to_callisto :: proc(glfw_mode: c.int) -> (callisto_mode: Cursor_Lock_Mode) {
    switch glfw_mode {
        case glfw.CURSOR_DISABLED:
            callisto_mode = .Disabled
        case glfw.CURSOR_HIDDEN:
            callisto_mode = .Hidden
        case glfw.CURSOR_NORMAL:
            fallthrough
        case:
            callisto_mode = .Normal
    }
    return
}

@(private)
cursor_lock_mode_callisto_to_glfw :: proc(callisto_mode: Cursor_Lock_Mode) -> (glfw_mode: c.int) {
    switch callisto_mode {
        case .Disabled:
            glfw_mode = glfw.CURSOR_DISABLED
        case .Hidden:
            glfw_mode = glfw.CURSOR_HIDDEN
        case .Normal:
            glfw_mode = glfw.CURSOR_NORMAL
    }
    return
}

@(private)
gamepad_button_glfw_to_callisto :: proc(glfw_mode: c.int) -> (callisto_mode: Gamepad_Button) {

    return
}

@(private)
gamepad_button_callisto_to_glfw :: proc(callisto_mode: Gamepad_Button) -> (glfw_mode: c.int) {

    return
}

@(private)
gamepad_axis_glfw_to_callisto :: proc(glfw_mode: c.int) -> (callisto_mode: Gamepad_Axis) {

    return
}

@(private)
gamepad_axis_callisto_to_glfw :: proc(callisto_mode: Gamepad_Axis) -> (glfw_mode: c.int) {

    return
}
