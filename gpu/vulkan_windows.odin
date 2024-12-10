#+private

package callisto_gpu

import "base:runtime"
import "core:log"
import win "core:sys/windows"
import vk "vulkan"
import "../config"
import "../common"

when RHI == "vulkan" {

        Window_Handle :: win.HWND 

        _vk_loader :: proc (d: ^Device) {
                vk_lib := win.LoadLibraryW(win.L("vulkan-1.dll"))
                if vk_lib == nil {
                        panic("Failed to load Vulkan DLL")
                }
                get_instance_proc_address := auto_cast win.GetProcAddress(vk_lib, "vkGetInstanceProcAddr")
                if get_instance_proc_address == nil {
                        panic("Failed to load Vulkan procs")
                }

                vk.load_proc_addresses_loader_vtable(get_instance_proc_address, &d.vtable)
        }

        _vk_query_queue_family_present_support :: proc(d: ^Device, pd: vk.PhysicalDevice, family: u32) -> bool {
                return bool(d.GetPhysicalDeviceWin32PresentationSupportKHR(pd, family))
        }



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

        _vk_window_get_size :: proc(window: common.Window) -> [2]u32 {
                rect: win.RECT
                ok := win.GetWindowRect(window, &rect)
                if !ok {
                        log.error("Failed to get window size")
                        return 0
                }

                return {u32(rect.right - rect.left), u32(rect.bottom - rect.top)}
        }

} // when RHI == "vulkan"
