package callisto_graphics_vkb

import vk "vendor:vulkan"
import vma "vulkan-memory-allocator"
import "core:log"

Graphics_Context :: struct {
    // destroy_stack:              [dynamic]Gpu_Resource_Entry,

    instance:                   vk.Instance,
    logger:                     log.Logger,
    debug_messenger:            vk.DebugUtilsMessengerEXT,
    allocator:                  vma.Allocator,
                              
    surface:                    vk.SurfaceKHR,
                              
    physical_device:            vk.PhysicalDevice,
    device:                     vk.Device,
                              
    graphics_queue:             vk.Queue,
    transfer_queue:             vk.Queue,
    compute_queue:              vk.Queue,

    graphics_queue_family_idx:  u32,
    transfer_queue_family_idx:  u32,
    compute_queue_family_idx:   u32,

    graphics_pool:              vk.CommandPool,
    transfer_pool:              vk.CommandPool,
    compute_pool:               vk.CommandPool,

    graphics_command_buffers:   []vk.CommandBuffer, // One per frame in flight
    transfer_command_buffer:    vk.CommandBuffer,

    swapchain:                  vk.SwapchainKHR,
    swapchain_format:           vk.Format,
    swapchain_extents:          vk.Extent2D,
    swapchain_images:           []vk.Image,
    swapchain_views:            []vk.ImageView,

    render_pass:                vk.RenderPass,
    render_pass_framebuffers:   []vk.Framebuffer,

    descriptor_layout_pass:     vk.DescriptorSetLayout,

    sync_structures:            []Sync_Structures,
    current_frame:              u32,
    current_image_index:        u32,
    
    clear_color:                [4]f32,
}

Queue_Families :: struct {
    has_compute:    bool,
    has_graphics:   bool,
    has_transfer:   bool,

    compute:        u32,
    graphics:       u32,
    transfer:       u32,
}

Sync_Structures :: struct {
    sem_image_available:    vk.Semaphore,
    sem_render_finished:    vk.Semaphore,
    fence_in_flight:        vk.Fence,
}

