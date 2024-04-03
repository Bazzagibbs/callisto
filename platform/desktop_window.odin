//+build windows, linux, darwin
package callisto_platform
import "core:log"
import "core:c"
import "vendor:glfw"
import "../config"
import "../platform"
import "core:strings"
import cc "../common"

when config.BUILD_PLATFORM == .Desktop {
    poll_events :: proc() {
        // TODO(input): this should only be run once per frame, no matter how many windows there are
        glfw.PollEvents()
    }
   
    // Allocates and initializes a Window structure.
    window_create :: proc(description: ^Display_Description) -> (window: Window, res: cc.Result) {
        wnd := new(Window_Desktop)

        glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API) // Disable OpenGL
        glfw.WindowHint(glfw.RESIZABLE, 0) /* glfw.FALSE */

        wnd.glfw_handle = glfw.CreateWindow(description.window_width, description.window_height, cstring(config.APP_NAME), nil, nil)
        if(wnd.glfw_handle == nil) {
            return nil, .Initialization_Failed
        }

        // Set up callbacks to glfw window. Note: these procs should no-op if an input context has not been linked with `set_input_sink()`
        // Keyboard
        glfw.SetKeyCallback(wnd.glfw_handle, glfw.KeyProc(_key_callback))
        glfw.SetCharCallback(wnd.glfw_handle, glfw.CharProc(_char_callback))
        // Mouse
        glfw.SetCursorPosCallback(wnd.glfw_handle, glfw.CursorPosProc(_cursor_position_callback))
        glfw.SetCursorEnterCallback(wnd.glfw_handle, glfw.CursorEnterProc(_cursor_enter_callback))
        glfw.SetMouseButtonCallback(wnd.glfw_handle, glfw.MouseButtonProc(_mouse_button_callback))
        glfw.SetScrollCallback(wnd.glfw_handle, glfw.ScrollProc(_scroll_callback))
        // Joystick
        // TODO(input)

        return to_handle(wnd), .Ok
    }

    window_destroy :: proc(window: Window) {
        wnd := from_handle(window)
        glfw.DestroyWindow(wnd.glfw_handle)
        free(wnd)
    }

    window_set_fullscreen :: proc(window: Window, fullscreen_mode: Fullscreen_Flag) {
        unimplemented()
    }

    window_set_size :: proc(window: Window, width, height: int) {
        wnd := from_handle(window)
        glfw.SetWindowSize(wnd.glfw_handle, c.int(width), c.int(height))
    }
   
   
    window_should_close :: proc(window: Window) -> bool {
        wnd := from_handle(window)
        return bool(glfw.WindowShouldClose(wnd.glfw_handle))
    }

    window_present :: proc(window: Window) {
        wnd := from_handle(window)
        glfw.SwapBuffers(wnd.glfw_handle)
    }


    cursor_set_lock :: proc(window: Window, mode: Cursor_Lock_Mode) {
        wnd := from_handle(window)
        glfw.SetInputMode(wnd.glfw_handle, glfw.CURSOR, c.int(mode))
    }

    mouse_set_raw_input :: proc(window: Window, use_raw: bool) {
        wnd := from_handle(window)
        glfw.SetInputMode(wnd.glfw_handle, glfw.RAW_MOUSE_MOTION, use_raw ? 1 : 0)
    }

    // Provides the window callback with an Input context to which its input events will be accumulated.
    input_bind :: proc(source: Window, sink: ^Input) {
        wnd := from_handle(source)
        glfw.SetWindowUserPointer(wnd.glfw_handle, sink)
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

    get_framebuffer_size :: proc(window: Window) -> (size: cc.ivec2) {
        wnd := from_handle(window)
        size.x, size.y = glfw.GetFramebufferSize(wnd.glfw_handle)
        return
    }

}
