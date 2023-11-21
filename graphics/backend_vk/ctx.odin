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

    // graphics_pool is in frame data
    transfer_pool:              vk.CommandPool,
    compute_pool:               vk.CommandPool,

    transfer_command_buffer:    vk.CommandBuffer,

    swapchain:                  vk.SwapchainKHR,
    swapchain_format:           vk.Format,
    swapchain_extents:          vk.Extent2D,
    swapchain_images:           []vk.Image,
    swapchain_views:            []vk.ImageView,

    render_pass:                vk.RenderPass,
    render_pass_framebuffers:   []vk.Framebuffer,

    descriptor_layout_pass:     vk.DescriptorSetLayout,

    clear_color:                [4]f32,

    current_frame:              u32,
    frame_data:                 []Frame_Data,
}

Frame_Data :: struct {
    image_index:                u32,

    graphics_pool:              vk.CommandPool,
    
    graphics_command_buffer:    vk.CommandBuffer,

    present_ready_sem:      vk.Semaphore,
    image_available_sem:    vk.Semaphore,
    in_flight_fence:        vk.Fence,
}

Queue_Families :: struct {
    has_compute:    bool,
    has_graphics:   bool,
    has_transfer:   bool,

    compute:        u32,
    graphics:       u32,
    transfer:       u32,
}


current_frame_data :: #force_inline proc(cg_ctx: ^Graphics_Context) -> ^Frame_Data {
    return &cg_ctx.frame_data[cg_ctx.current_frame]
}

current_image :: #force_inline proc(cg_ctx: ^Graphics_Context) -> vk.Image {
    return cg_ctx.swapchain_images[current_frame_data(cg_ctx).image_index]
}
