package callisto_platform

import "../common"
import "../config"
import "vendor:glfw"
import "core:log"

when config.BUILD_PLATFORM == .Desktop {

    glfw_user_count : uint = 0


    Window_Handle_Glfw :: glfw.WindowHandle
    


    init :: proc() -> (res: common.Result) {
        ok := glfw.Init()
        if !ok do return .Initialization_Failed

        glfw_user_count += 1;
        return .Ok
    }

    destroy :: proc() {
        if glfw_user_count == 0 do return

        glfw_user_count -= 1;
        if (glfw_user_count == 0) {
            glfw.Terminate()
        }
    }

    get_vk_proc_address      :: glfw.GetInstanceProcAddress

    create_vk_window_surface :: glfw.CreateWindowSurface
}
