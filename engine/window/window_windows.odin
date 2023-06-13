package callisto_window_windows
import "core:log"
import "vendor:glfw"

window: glfw.WindowHandle

// TODO: load these values from a config file at compile time
title :: "Callisto"
width :: 640
height :: 480

init :: proc() -> (success: bool) {
    log.info("Initializing window: GLFW Windows")

    glfw.Init()
   
    glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API) // Disable OpenGL
    glfw.WindowHint(glfw.RESIZABLE, 0 /* glfw.FALSE */)
    window = glfw.CreateWindow(width, height, "Callisto", nil, nil)

    if(window == nil) {
        glfw.Terminate()
        return false
    }
    

    return true
}


should_close :: proc() -> bool {
    return bool(glfw.WindowShouldClose(window))
}


poll_events :: proc() {
    glfw.PollEvents()
}


shutdown :: proc() {
    log.info("Shutting down window")
    glfw.DestroyWindow(window)
    glfw.Terminate()
}