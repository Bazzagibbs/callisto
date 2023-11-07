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

    
    poll_events :: proc() {
        // TODO: this should only be run once per frame, no matter how many windows there are
        glfw.PollEvents()
    }
    
    init_window :: proc(window_ctx: ^Window_Context) -> ( ok: bool) {
        global_user_count += 1

        glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API) // Disable OpenGL
        glfw.WindowHint(glfw.RESIZABLE, 0) /* glfw.FALSE */

        window_ctx.handle = glfw.CreateWindow(config.WINDOW_WIDTH, config.WINDOW_HEIGHT, cstring(config.APP_NAME), nil, nil)
        if(window_ctx.handle == nil) {
            return false
        }

        // Set up callbacks to glfw window. Note: these procs should no-op if an input context has not been linked with `set_input_sink()`
        // Keyboard
        glfw.SetKeyCallback(window_ctx.handle, glfw.KeyProc(_key_callback))
        glfw.SetCharCallback(window_ctx.handle, glfw.CharProc(_char_callback))
        // Mouse
        glfw.SetCursorPosCallback(window_ctx.handle, glfw.CursorPosProc(_cursor_position_callback))
        glfw.SetCursorEnterCallback(window_ctx.handle, glfw.CursorEnterProc(_cursor_enter_callback))
        glfw.SetMouseButtonCallback(window_ctx.handle, glfw.MouseButtonProc(_mouse_button_callback))
        glfw.SetScrollCallback(window_ctx.handle, glfw.ScrollProc(_scroll_callback))
        // Joystick
        // TODO

        return true
    }

    shutdown_window :: proc(window_ctx: ^Window_Context) {
        global_user_count -= 1
        glfw.DestroyWindow(window_ctx.handle)
    }

    set_window_fullscreen_mode :: proc(window_ctx: ^Window_Context, fullscreen_mode: Fullscreen_Mode) {

    }

    set_window_size :: proc(window_ctx: ^Window_Context, width, height: int) {
        glfw.SetWindowSize(window_ctx.handle, c.int(width), c.int(height))
    }
   
   
    should_window_close :: proc(window_ctx: ^Window_Context) -> bool {
        return bool(glfw.WindowShouldClose(window_ctx.handle))
    }

    set_cursor_lock :: proc(window_ctx: ^Window_Context, mode: Cursor_Lock_Mode) {
        glfw.SetInputMode(window_ctx.handle, glfw.CURSOR, c.int(mode))
    }

    set_mouse_input_raw :: proc(window_ctx: ^Window_Context, use_raw: bool) {
        glfw.SetInputMode(window_ctx.handle, glfw.RAW_MOUSE_MOTION, use_raw ? 1 : 0)
    }

    // Provides the window callback with an Input context to which its input events will be accumulated.
    set_input_sink :: proc(source: ^Window_Context, sink: ^Input_Context) {
        glfw.SetWindowUserPointer(source.handle, sink)
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
