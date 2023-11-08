package callisto_graphics_vkb

import vk "vendor:vulkan"
import "core:log"

Graphics_Context :: struct {
    logger:             log.Logger,
    debug_messenger:    vk.DebugUtilsMessengerEXT,
    instance:           vk.Instance,
    physical_device:    vk.PhysicalDevice,
    device:             vk.Device,
    surface:            vk.SurfaceKHR,
}
