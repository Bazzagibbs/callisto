//+build windows, linux, darwin
//+private
package callisto_engine_renderer

import "core:log"
import vk "vendor:vulkan"
import vk_impl "vulkan"
import "core:strings"

state: vk_impl.State = {}

_init :: proc() -> (ok: bool) {
    using state
    log.info("Initializing renderer: Vulkan")

    state.instance = vk_impl.create_instance() or_return
    defer if !ok do vk.DestroyInstance(state.instance, nil)

    // First "state" pointer is always const. Explicitly pass pointers to mutable data in separate params
    debug_messenger = vk_impl.create_debug_messenger(&state) or_return
    defer if !ok do vk.DestroyDebugUtilsMessengerEXT(instance, debug_messenger, nil)
    
    surface = vk_impl.create_surface(&state) or_return
    defer if !ok do vk.DestroySurfaceKHR(instance, surface, nil)

    physical_device = vk_impl.select_physical_device(&state) or_return
    
    device, queue_family_indices, queues = vk_impl.create_logical_device(&state) or_return
    defer if !ok do vk.DestroyDevice(device, nil)

    swapchain, swapchain_details = vk_impl.create_swapchain(&state) or_return
    defer if !ok do vk.DestroySwapchainKHR(device, swapchain, nil)

    vk_impl.get_swapchain_images(&state, &swapchain_images)

    vk_impl.create_swapchain_image_views(&state, &swapchain_image_views) or_return
    defer if !ok do vk_impl.destroy_swapchain_image_views(&state, &swapchain_image_views)

    render_pass = vk_impl.create_render_pass(&state) or_return
    defer if !ok do vk.DestroyRenderPass(device, render_pass, nil)

    pipeline, pipeline_layout = vk_impl.create_graphics_pipeline(&state) or_return
    defer if !ok do vk.DestroyPipelineLayout(device, pipeline_layout, nil)
    defer if !ok do vk.DestroyPipeline(device, pipeline, nil)

    vk_impl.create_framebuffers(&state, &framebuffers) or_return
    defer if !ok do vk_impl.destroy_framebuffers(&state, &framebuffers)

    command_pool = vk_impl.create_command_pool(&state) or_return
    defer if !ok do vk.DestroyCommandPool(device, command_pool, nil)

    command_buffer = vk_impl.create_command_buffer(&state) or_return
    defer if !ok do vk.FreeCommandBuffers(device, command_pool, 1, &command_buffer)

    semaphore_image_available = vk_impl.create_semaphore(&state) or_return
    defer if !ok do vk.DestroySemaphore(device, semaphore_image_available, nil)
    semaphore_render_finished = vk_impl.create_semaphore(&state) or_return
    defer if !ok do vk.DestroySemaphore(device, semaphore_render_finished, nil)
    fence_in_flight = vk_impl.create_fence(&state) or_return
    defer if !ok do vk.DestroyFence(device, fence_in_flight, nil)

    return true
}

_shutdown :: proc() {
    log.info("Shutting down renderer")
    using state

    vk.DeviceWaitIdle(device)
    defer vk.DestroyInstance(instance, nil)
    defer vk.DestroyDebugUtilsMessengerEXT(instance, debug_messenger, nil)
    defer vk.DestroySurfaceKHR(instance, surface, nil)
    defer vk.DestroyDevice(device, nil)
    defer vk.DestroyCommandPool(device, command_pool, nil)
    defer vk.DestroySwapchainKHR(device, swapchain, nil)
    defer vk_impl.destroy_swapchain_image_views(&state, &swapchain_image_views)
    defer vk.DestroyRenderPass(device, render_pass, nil)
    defer vk.DestroyPipelineLayout(device, pipeline_layout, nil)
    defer vk.DestroyPipeline(device, pipeline, nil)
    defer vk_impl.destroy_framebuffers(&state, &framebuffers)
    defer vk.FreeCommandBuffers(device, command_pool, 1, &command_buffer)
    defer vk.DestroySemaphore(device, semaphore_image_available, nil)
    defer vk.DestroySemaphore(device, semaphore_render_finished, nil)
    defer vk.DestroyFence(device, fence_in_flight, nil)

}


_cmd_draw_frame :: proc() {
    using state
    vk.WaitForFences(device, 1, &fence_in_flight, true, max(u64))
    vk.ResetFences(device, 1, &fence_in_flight)

    target_image_index = 0
    vk.AcquireNextImageKHR(device, swapchain, max(u64), semaphore_image_available, {}, &target_image_index)
    vk.ResetCommandBuffer(command_buffer, {})
    vk_impl.record_command_buffer(&state, command_buffer)
    vk_impl.submit_command_buffer(&state, command_buffer)
}
