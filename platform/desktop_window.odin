//+build windows, linux, darwin
package callisto_platform
import "core:log"
import "core:c"
import "vendor:glfw"
import "../config"
import "../platform"
import "core:strings"

when config.BUILD_PLATFORM == .Desktop {
    global_user_count: int = 0 // Keeps track of the number of active windows in use. Only disables GLFW when zero.
    


    init :: proc(window_ctx: ^Window_Context) -> (ok: bool) {
        log.info("Initializing window: GLFW Windows")

        if global_user_count <= 0 {
            bool(glfw.Init()) or_return
        }
        global_user_count += 1

        window_ctx.handle, ok = create_window(); if !ok {
            log.fatal("Failed to create window")
        }
        return
    }

    shutdown :: proc(window_ctx: ^Window_Context) {
        log.info("Shutting down window")
        
        global_user_count -= 1
        if global_user_count <= 0 {
            glfw.Terminate()
        }

        destroy_window(window_ctx.handle)
    }
    
    poll_events :: proc() {
        // TODO: this should only be run once per frame, no matter how many windows there are
        glfw.PollEvents()
    }
    
    create_window :: proc() -> (window_handle: Window_Handle, ok: bool) {
        global_user_count += 1

        glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API) // Disable OpenGL
        glfw.WindowHint(glfw.RESIZABLE, 0) /* glfw.FALSE */

        window_handle = glfw.CreateWindow(config.WINDOW_WIDTH, config.WINDOW_HEIGHT, cstring(config.APP_NAME), nil, nil)
        if(window_handle == nil) {
            return {}, false
        }

        glfw.SetWindowUserPointer(window_handle, &window_ctx)

        // Set up callbacks to glfw window
        // Keyboard
        glfw.SetKeyCallback(window_handle, glfw.KeyProc(_key_callback))
        glfw.SetCharCallback(window_handle, glfw.CharProc(_char_callback))
        // Mouse
        glfw.SetCursorPosCallback(window_handle, glfw.CursorPosProc(_cursor_position_callback))
        glfw.SetCursorEnterCallback(window_handle, glfw.CursorEnterProc(_cursor_enter_callback))
        glfw.SetMouseButtonCallback(window_handle, glfw.MouseButtonProc(_mouse_button_callback))
        glfw.SetScrollCallback(window_handle, glfw.ScrollProc(_scroll_callback))
        // Joystick
        // TODO

        return window_handle, true
    }

    destroy_window :: proc(window_handle: Window_Handle) {
        global_user_count -= 1
        glfw.DestroyWindow(window_handle)
    }

    set_size :: proc(width, height: int) {
        glfw.SetWindowSize(window_ctx.handle, c.int(width), c.int(height))
    }
   
   
    should_close :: proc() -> bool {
        return bool(glfw.WindowShouldClose(window_ctx.handle))
    }

    set_cursor_lock :: proc(mode: Cursor_Lock_Mode) {
        glfw.SetInputMode(window_ctx.handle, glfw.CURSOR, c.int(mode))
    }

    set_mouse_input_raw :: proc(use_raw: bool) {
        glfw.SetInputMode(window_ctx.handle, glfw.RAW_MOUSE_MOTION, use_raw ? 1 : 0)
    }


    // Allocates a slice, and _n_ strings. Caller is responsible for deleting strings and slice.
    get_required_extensions :: proc() -> []cstring {
        temp_cstrs := glfw.GetRequiredInstanceExtensions()

        exts := make([]cstring, len(temp_cstrs))
        for cstr, i in temp_cstrs {
            exts[i], _ = strings.clone_to_cstring(string(cstr))
        }

        return exts
    }

}
