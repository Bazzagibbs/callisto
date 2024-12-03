#+private

package callisto_gpu

import vk "vulkan"
import win "core:sys/windows"

Window_Handle :: win.HWND 


_vk_surface_init :: proc(d: ^Device, sc: ^Swapchain, init_info: ^Swapchain_Init_Info) -> Result {
        surface_info := vk.Win32SurfaceCreateInfoKHR {
                sType     = .WIN32_SURFACE_CREATE_INFO_KHR,
                hwnd      = init_info.window,
                hinstance = win.HINSTANCE(win.GetModuleHandleW(nil)),
        }

        vkres := d.CreateWin32SurfaceKHR(d.instance, &surface_info, nil, &sc.surface)
        check_result(vkres) or_return

        return .Ok
}



_vk_surface_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        d.DestroySurfaceKHR(d.instance, sc.surface, nil)
}
