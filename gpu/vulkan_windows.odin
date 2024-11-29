package callisto_gpu

import "base:runtime"
import win "core:sys/windows"
import vk "vendor:vulkan"
import "../config"

// when config.RHI == "vulkan"

@(init) 
_vk_loader :: proc "contextless" () {
        context = runtime.default_context()

        vk_lib := win.LoadLibraryW(win.L("vulkan-1.dll"))
        if vk_lib == nil {
                panic("Failed to load Vulkan DLL")
        }
        get_instance_proc_address := auto_cast win.GetProcAddress(vk_lib, "vkGetInstanceProcAddr")
        if get_instance_proc_address == nil {
                panic("Failed to load Vulkan procs")
        }

        vk.load_proc_addresses_global(get_instance_proc_address)
}
