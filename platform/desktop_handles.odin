package callisto_platform

import "../common"
import "../config"

when config.BUILD_PLATFORM == .Desktop {
    Window_Desktop :: struct {
        glfw_handle: Window_Handle_Glfw,
    }

    to_handle :: proc(window_desktop: ^Window_Desktop) -> Window {
        return transmute(Window)window_desktop
    }

    from_handle :: proc(handle: Window) -> ^Window_Desktop {
        return transmute(^Window_Desktop)handle
    }
}
