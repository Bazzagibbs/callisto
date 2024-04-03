//+private
package callisto_platform

import "../config"
import "vendor:glfw"
import "core:c"
import "core:fmt"

when config.BUILD_PLATFORM == .Desktop {

    SCROLL_WHEEL_STEP_THRESHOLD :: 0.1

    _key_callback :: proc(window: glfw.WindowHandle, key, scancode, action, mods: c.int){
        ictx := (^Input)(glfw.GetWindowUserPointer(window))
        if ictx == nil do return

        if key >= len(ictx.kbm_down_buffer.keys) || key < 0 do return

        switch Button_Action(action) {
            case .Press:
                ictx.kbm_down_buffer.keys[key] = true
                ictx.kbm_pressed_buffer.keys[key] = true
        
            case .Release:
                ictx.kbm_up_buffer.keys[key] = true
                ictx.kbm_pressed_buffer.keys[key] = false

            case .Repeat:
        }
    }

    _char_callback :: proc(window: glfw.WindowHandle, key, scancode, action, mods: c.int) {
        ictx := (^Input)(glfw.GetWindowUserPointer(window))
        if ictx == nil do return
    }

    _cursor_position_callback :: proc(window: glfw.WindowHandle, x_pos, y_pos: c.double){
        ictx := (^Input)(glfw.GetWindowUserPointer(window))
        if ictx == nil do return

        ictx.mouse_pos = {x_pos, y_pos}
    }

    _cursor_enter_callback :: proc(window: glfw.WindowHandle, entered: c.int) {
        ictx := (^Input)(glfw.GetWindowUserPointer(window))
        if ictx == nil do return
    }

    _mouse_button_callback :: proc(window: glfw.WindowHandle, button, action, mods: c.int) {
        ictx := (^Input)(glfw.GetWindowUserPointer(window))
        if ictx == nil do return
        switch Button_Action(action) {
            case .Press:
                ictx.kbm_down_buffer.mouse_buttons += {Mouse_Button(button)}
                ictx.kbm_pressed_buffer.mouse_buttons += {Mouse_Button(button)}
            case .Release:
                ictx.kbm_up_buffer.mouse_buttons += {Mouse_Button(button)}
                ictx.kbm_pressed_buffer.mouse_buttons -= {Mouse_Button(button)}
            case .Repeat:
        }
    }

    _scroll_callback :: proc(window: glfw.WindowHandle, x_offset, y_offset: c.double) {
        ictx := (^Input)(glfw.GetWindowUserPointer(window))
        if ictx == nil do return

        // Treat scroll as axis
        ictx.scroll_delta += {x_offset, y_offset}

        // Treat scroll as buttons
        if y_offset < -SCROLL_WHEEL_STEP_THRESHOLD {
            ictx.kbm_down_buffer.mouse_buttons += {.Wheel_Down}
            ictx.kbm_up_buffer.mouse_buttons += {.Wheel_Down}
            ictx.kbm_pressed_buffer.mouse_buttons += {.Wheel_Down}
        }
        if y_offset > SCROLL_WHEEL_STEP_THRESHOLD {
            ictx.kbm_down_buffer.mouse_buttons += {.Wheel_Up}
            ictx.kbm_up_buffer.mouse_buttons += {.Wheel_Up}
            ictx.kbm_pressed_buffer.mouse_buttons += {.Wheel_Up}
        }
    }
}
