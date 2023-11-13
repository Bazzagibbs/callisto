package callisto_graphics_vkb

import vk "vendor:vulkan"
import "core:log"

Graphics_Context :: struct {
    instance:           vk.Instance,
    logger:             log.Logger,
    debug_messenger:    vk.DebugUtilsMessengerEXT,
    
    surface:            vk.SurfaceKHR,

    physical_device:    vk.PhysicalDevice,
    device:             vk.Device,

    swapchain:          vk.SwapchainKHR,
    swapchain_format:   vk.Format,
    swapchain_images:   []vk.Image,
    swapchain_views:    []vk.ImageView,
}

Queue_Families :: struct {
    has_compute: bool,
    has_graphics: bool,
    has_transfer: bool,

    compute: u32,
    graphics: u32,
    transfer: u32,
}
