package callisto_gpu

import "base:runtime"
import win "core:sys/windows"
import vk "../vendor_mod/vulkan"
import "../config"

// when config.RHI == "vulkan"

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
