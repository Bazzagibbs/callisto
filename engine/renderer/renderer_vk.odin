//+build windows, linux, darwin
//+private
package callisto_engine_renderer

import "core:log"
import vk "vendor:vulkan"
import vk_impl "vulkan"
import "core:strings"
// TODO: refactor to a State struct after we have a rainbow triangle
debug_messenger: vk.DebugUtilsMessengerEXT = {}
instance: vk.Instance = {}
surface: vk.SurfaceKHR = {}
physical_device: vk.PhysicalDevice = {}
device: vk.Device = {}
queue_family_indices: vk_impl.Queue_Family_Indices = {}
queues: vk_impl.Queue_Handles = {}
swapchain: vk.SwapchainKHR = {}
swapchain_details: vk_impl.Swapchain_Details = {}
swapchain_images: [dynamic]vk.Image = {}
swapchain_image_views: [dynamic]vk.ImageView = {}
render_pass: vk.RenderPass = {}
pipeline: vk.Pipeline = {}
pipeline_layout: vk.PipelineLayout = {}
framebuffers: [dynamic]vk.Framebuffer = {}
command_pool: vk.CommandPool = {}
command_buffer: vk.CommandBuffer = {}
semaphore_image_available: vk.Semaphore = {}
semaphore_render_finished: vk.Semaphore = {}
fence_in_flight: vk.Fence = {}

_init :: proc() -> (ok: bool) {
    log.info("Initializing renderer: Vulkan")
    instance = vk_impl.create_instance() or_return
    defer if !ok do vk.DestroyInstance(instance, nil)

    debug_messenger = vk_impl.create_debug_messenger(instance) or_return
    defer if !ok do vk.DestroyDebugUtilsMessengerEXT(instance, debug_messenger, nil)
    
    surface = vk_impl.create_surface(instance) or_return
    defer if !ok do vk.DestroySurfaceKHR(instance, surface, nil)

    physical_device = vk_impl.select_physical_device(instance, surface) or_return
    
    device, queue_family_indices, queues = vk_impl.create_logical_device(physical_device, surface) or_return
    defer if !ok do vk.DestroyDevice(device, nil)

    swapchain, 
    swapchain_details = vk_impl.create_swapchain(physical_device, device, surface) or_return
    defer if !ok do vk.DestroySwapchainKHR(device, swapchain, nil)

    vk_impl.get_swapchain_images(device, swapchain, &swapchain_images)

    vk_impl.create_swapchain_image_views(device, &swapchain_details, &swapchain_images, &swapchain_image_views) or_return
    defer if !ok do vk_impl.destroy_swapchain_image_views(device, &swapchain_image_views)

    render_pass = vk_impl.create_render_pass(device, &swapchain_details) or_return
    defer if !ok do vk.DestroyRenderPass(device, render_pass, nil)

    pipeline, pipeline_layout = vk_impl.create_graphics_pipeline(device, &swapchain_details, render_pass) or_return
    defer if !ok do vk.DestroyPipelineLayout(device, pipeline_layout, nil)
    defer if !ok do vk.DestroyPipeline(device, pipeline, nil)

    vk_impl.create_framebuffers(device, &swapchain_details, &swapchain_image_views, render_pass, &framebuffers) or_return
    defer if !ok do vk_impl.destroy_framebuffers(device, &framebuffers)

    command_pool = vk_impl.create_command_pool(device, &queue_family_indices) or_return
    defer if !ok do vk.DestroyCommandPool(device, command_pool, nil)

    command_buffer = vk_impl.create_command_buffer(device, command_pool) or_return
    defer if !ok do vk.FreeCommandBuffers(device, command_pool, 1, &command_buffer)

    semaphore_image_available = vk_impl.create_semaphore(device) or_return
    defer if !ok do vk.DestroySemaphore(device, semaphore_image_available, nil)
    semaphore_render_finished = vk_impl.create_semaphore(device) or_return
    defer if !ok do vk.DestroySemaphore(device, semaphore_render_finished, nil)
    fence_in_flight = vk_impl.create_fence(device) or_return
    defer if !ok do vk.DestroyFence(device, fence_in_flight, nil)

    return true
}

_shutdown :: proc() {
    log.info("Shutting down renderer")
    vk.DeviceWaitIdle(device)
    defer vk.DestroyInstance(instance, nil)
    defer vk.DestroyDebugUtilsMessengerEXT(instance, debug_messenger, nil)
    defer vk.DestroySurfaceKHR(instance, surface, nil)
    defer vk.DestroyDevice(device, nil)
    defer vk.DestroyCommandPool(device, command_pool, nil)
    defer vk.DestroySwapchainKHR(device, swapchain, nil)
    defer vk_impl.destroy_swapchain_image_views(device, &swapchain_image_views)
    defer vk.DestroyRenderPass(device, render_pass, nil)
    defer vk.DestroyPipelineLayout(device, pipeline_layout, nil)
    defer vk.DestroyPipeline(device, pipeline, nil)
    defer vk_impl.destroy_framebuffers(device, &framebuffers)
    defer vk.FreeCommandBuffers(device, command_pool, 1, &command_buffer)
    defer vk.DestroySemaphore(device, semaphore_image_available, nil)
    defer vk.DestroySemaphore(device, semaphore_render_finished, nil)
    defer vk.DestroyFence(device, fence_in_flight, nil)

}


_cmd_draw_frame :: proc() {
    vk.WaitForFences(device, 1, &fence_in_flight, true, max(u64))
    vk.ResetFences(device, 1, &fence_in_flight)

    image_index: u32
    vk.AcquireNextImageKHR(device, swapchain, max(u64), semaphore_image_available, {}, &image_index)
    vk.ResetCommandBuffer(command_buffer, {})
    vk_impl.record_command_buffer(command_buffer, render_pass, &swapchain_details, framebuffers[image_index], pipeline)
    vk_impl.submit_command_buffer(command_buffer, queues.graphics, swapchain, image_index, semaphore_image_available, semaphore_render_finished, fence_in_flight)
}
