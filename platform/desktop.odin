package callisto_platform

import "../config"
import "vendor:glfw"
import "core:log"

when config.BUILD_PLATFORM == .Desktop {

    Window_Handle :: glfw.WindowHandle

    Window_Context :: struct {
        handle: Window_Handle,
        input: Input_Context,
    }

    init :: proc() -> (ok: bool) {
        log.info("Initializing platform: GLFW Windows")

        if global_user_count <= 0 {
            ok = bool(glfw.Init())
            if !ok do return false
        }
        global_user_count += 1

        return true
    }

    shutdown :: proc() {
        log.info("Shutting down platform")
        
        global_user_count -= 1
        if global_user_count <= 0 {
            glfw.Terminate()
        }
    }

    get_vk_proc_address :: glfw.GetInstanceProcAddress

    create_vk_window_surface :: glfw.CreateWindowSurface
}
