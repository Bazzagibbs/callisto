//+build windows, linux, darwin
//+private
package callisto_window
import "core:log"
import "core:c"
import "vendor:glfw"


// TODO: load these values from a config file at compile time
title :: "Callisto"
width :: 640
height :: 480

// Cast rawptr handle to glfw handle
_handle :: #force_inline proc() -> glfw.WindowHandle {
    return glfw.WindowHandle(handle)
}

_init :: proc() -> (success: bool) {
    log.debug("Initializing window: GLFW Windows")

    glfw.Init()
   
    glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API) // Disable OpenGL
    glfw.WindowHint(glfw.RESIZABLE, 0) /* glfw.FALSE */
    handle = glfw.CreateWindow(width, height, title, nil, nil)

    if(handle == nil) {
        glfw.Terminate()
        return false
    }
    
    return true
}

_shutdown :: proc() {
    log.debug("Shutting down window")
    glfw.DestroyWindow(_handle())
    glfw.Terminate()
}



_should_close :: proc() -> bool {
    return bool(glfw.WindowShouldClose(_handle()))
}

_poll_events :: proc() {
    glfw.PollEvents()
}

_set_window_size :: proc(width, height: int) {
    glfw.SetWindowSize(_handle(), c.int(width), c.int(height))
}