package callisto_gpu

import vk "../vendor_mod/vulkan"


_vk_swapchain_init :: proc(d: ^Device, sc: ^Swapchain, init_info: ^Swapchain_Init_Info) -> (res: Result) {
        format: vk.SurfaceFormatKHR
        {
                // d.Query

        }

        unimplemented()
}

_vk_swapchain_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        unimplemented()
}
