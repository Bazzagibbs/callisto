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
    graphics_queue:     vk.Queue,
    transfer_queue:     vk.Queue,
    compute_queue:      vk.Queue,
    graphics_queue_family_idx: u32,
    transfer_queue_family_idx: u32,
    compute_queue_family_idx:  u32,

    swapchain:          vk.SwapchainKHR,
    swapchain_format:   vk.Format,
    swapchain_extents:  vk.Extent2D,
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
