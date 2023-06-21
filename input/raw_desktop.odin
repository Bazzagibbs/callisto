package callisto_input_raw

// TO BE IMPLEMENTED:
// Gamepad bindings
// Text callback handling


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

set_cursor_lock :: proc(mode: Cursor_Lock_Mode) {
    glfw_mode := cursor_lock_mode_callisto_to_glfw(mode)
    glfw.SetInputMode(window.handle, glfw.CURSOR, glfw_mode)
}

// Set whether mouse input data should skip acceleration curve processing or not.
set_mouse_input_raw :: proc(use_raw: bool = true) {
    glfw.SetInputMode(window.handle, glfw.RAW_MOUSE_MOTION, c.int(use_raw))
}


// GLFW-specific callbacks
@(private)
key_callback :: proc(window: glfw.WindowHandle, key, scancode, action, mods: c.int){
    switch Button_Press_Action(action) {
        case .Press:
            input_accumulator.kbm_down_buffer.keys[key] = true
            input_accumulator.kbm_pressed_buffer.keys[key] = true
    
        case .Release:
            input_accumulator.kbm_up_buffer.keys[key] = true
            input_accumulator.kbm_pressed_buffer.keys[key] = false

        case .Repeat:
    }
}

@(private)
char_callback :: proc(window: glfw.WindowHandle, key, scancode, action, mods: c.int){

}

@(private)
cursor_position_callback :: proc(window: glfw.WindowHandle, x_pos, y_pos: c.double){
    input_accumulator.mouse_pos = {x_pos, y_pos}
}

@(private)
cursor_enter_callback :: proc(window: glfw.WindowHandle, entered: c.int) {

}

@(private)
mouse_button_callback :: proc(window: glfw.WindowHandle, button, action, mods: c.int) {
    switch Button_Press_Action(action) {
        case .Press:
            input_accumulator.kbm_down_buffer.mouse_buttons += {Mouse_Button(button)}
            input_accumulator.kbm_pressed_buffer.mouse_buttons += {Mouse_Button(button)}
        case .Release:
            input_accumulator.kbm_up_buffer.mouse_buttons += {Mouse_Button(button)}
            input_accumulator.kbm_pressed_buffer.mouse_buttons -= {Mouse_Button(button)}
        case .Repeat:
    }
}

@(private)
scroll_callback :: proc(window: glfw.WindowHandle, x_offset, y_offset: c.double) {
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
    return Cursor_Lock_Mode(glfw_mode)
}

@(private)
cursor_lock_mode_callisto_to_glfw :: proc(callisto_mode: Cursor_Lock_Mode) -> (glfw_mode: c.int) {
    return c.int(callisto_mode)
}


// TODO: implement gamepad functionality
@(private)
gamepad_button_glfw_to_callisto :: proc(glfw_mode: c.int) -> (callisto_mode: Gamepad_Button) {
    return .Start
}

@(private)
gamepad_button_callisto_to_glfw :: proc(callisto_mode: Gamepad_Button) -> (glfw_mode: c.int) {
    return 0 
}

@(private)
gamepad_axis_glfw_to_callisto :: proc(glfw_mode: c.int) -> (callisto_mode: Gamepad_Axis) {
    return .Left_Y
}

@(private)
gamepad_axis_callisto_to_glfw :: proc(callisto_mode: Gamepad_Axis) -> (glfw_mode: c.int) {
    return 0 
}
