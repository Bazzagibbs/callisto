package callisto_platform

import "../config"
import "vendor:glfw"

when config.BUILD_PLATFORM == .Desktop {

    Window_Handle :: glfw.WindowHandle

    Window_Context :: struct {
        handle: Window_Handle,
        input: Input_Context,
    }


}
