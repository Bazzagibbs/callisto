package callisto_graphics_vulkan

import "../../common"
import "core:log"
import vk "vendor:vulkan"

Result :: common.Result

Renderer_Impl :: struct {
    instance        : vk.Instance,
    physical_device : vk.PhysicalDevice,
    device          : vk.Device,
    logger          : log.Logger,
    debug_messenger : vk.DebugUtilsMessengerEXT,
}

Gpu_Image_Impl :: struct {}

Gpu_Buffer_Impl :: struct {}
