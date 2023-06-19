package callisto_window
import "core:log"
import "core:c"
import "vendor:glfw"

handle: glfw.WindowHandle

// TODO: load these values from a config file at compile time
title :: "Callisto"
width :: 640
height :: 480

init :: proc() -> (success: bool) {
    log.info("Initializing window: GLFW Windows")

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

shutdown :: proc() {
    log.info("Shutting down window")
    glfw.DestroyWindow(handle)
    glfw.Terminate()
}



should_close :: proc() -> bool {
    return bool(glfw.WindowShouldClose(handle))
}


poll_events :: proc() {
    glfw.PollEvents()
}

