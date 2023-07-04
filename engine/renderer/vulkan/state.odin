package callisto_engine_renderer_vulkan

import vk "vendor:vulkan"

State :: struct {
    debug_messenger: vk.DebugUtilsMessengerEXT,
    instance: vk.Instance,
    surface: vk.SurfaceKHR,
    physical_device: vk.PhysicalDevice,
    device: vk.Device,
    queue_family_indices: Queue_Family_Indices,
    queues: Queue_Handles,
    swapchain: vk.SwapchainKHR,
    swapchain_details: Swapchain_Details,
    target_image_index: u32,
    images: [dynamic]vk.Image,
    image_views: [dynamic]vk.ImageView,
    render_pass: vk.RenderPass,
    pipeline: vk.Pipeline,
    pipeline_layout: vk.PipelineLayout,
    framebuffers: [dynamic]vk.Framebuffer,
    command_pool: vk.CommandPool,
    command_buffer: vk.CommandBuffer,
    semaphore_image_available: vk.Semaphore,
    semaphore_render_finished: vk.Semaphore,
    fence_in_flight: vk.Fence,
}

Queue_Family_Indices :: struct {
    graphics: Maybe(u32),
    present: Maybe(u32),
}

Queue_Handles :: struct {
    graphics: vk.Queue,
    present: vk.Queue,
}

Swapchain_Details :: struct {
    capabilities: vk.SurfaceCapabilitiesKHR,
    format: vk.SurfaceFormatKHR,
    present_mode: vk.PresentModeKHR,
    extent: vk.Extent2D,
}
