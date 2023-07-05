//+build windows, linux, darwin
//+private
package callisto_engine_renderer

import "core:log"
import vk "vendor:vulkan"
import vk_impl "vulkan"
import "core:strings"
import "../../config"

state: vk_impl.State = {}

_init :: proc() -> (ok: bool) {
    using state
    log.info("Initializing renderer: Vulkan")

    vk_impl.create_instance(&instance) or_return
    defer if !ok do vk.DestroyInstance(state.instance, nil)
 
    // First "state" pointer is always const. Explicitly pass pointers to mutable data in separate params
    vk_impl.create_debug_messenger(&state, &debug_messenger) or_return
    defer if !ok do vk.DestroyDebugUtilsMessengerEXT(instance, debug_messenger, nil)
    
    vk_impl.create_surface(&state, &surface) or_return
    defer if !ok do vk.DestroySurfaceKHR(instance, surface, nil)

    vk_impl.select_physical_device(&state, &physical_device) or_return
    
    vk_impl.create_logical_device(&state, &device, &queue_family_indices, &queues) or_return
    defer if !ok do vk.DestroyDevice(device, nil)

    vk_impl.create_swapchain(&state, &swapchain, &swapchain_details) or_return
    defer if !ok do vk.DestroySwapchainKHR(device, swapchain, nil)

    vk_impl.get_images(&state, &state.images)

    vk_impl.create_image_views(&state, &state.image_views) or_return
    defer if !ok do vk_impl.destroy_image_views(&state, &state.image_views)

    vk_impl.create_render_pass(&state, &render_pass) or_return
    defer if !ok do vk.DestroyRenderPass(device, render_pass, nil)

    vk_impl.create_graphics_pipeline(&state, &pipeline, &pipeline_layout) or_return
    defer if !ok do vk.DestroyPipelineLayout(device, pipeline_layout, nil)
    defer if !ok do vk.DestroyPipeline(device, pipeline, nil)

    vk_impl.create_framebuffers(&state, &framebuffers) or_return
    defer if !ok do vk_impl.destroy_framebuffers(&state, &framebuffers)

    vk_impl.create_command_pool(&state, &command_pool) or_return
    defer if !ok do vk.DestroyCommandPool(device, command_pool, nil)

    vk_impl.create_command_buffers(&state, config.RENDERER_FRAMES_IN_FLIGHT, &command_buffers) or_return
    defer if !ok do vk.FreeCommandBuffers(device, command_pool, u32(len(command_buffers)), raw_data(command_buffers))

    vk_impl.create_semaphores(&state, config.RENDERER_FRAMES_IN_FLIGHT, &image_available_semaphores) or_return
    defer if !ok do vk_impl.destroy_semaphores(&state, &image_available_semaphores)
    vk_impl.create_semaphores(&state, config.RENDERER_FRAMES_IN_FLIGHT, &render_finished_semaphores) or_return
    defer if !ok do vk_impl.destroy_semaphores(&state, &render_finished_semaphores)
    vk_impl.create_fences(&state, config.RENDERER_FRAMES_IN_FLIGHT, &in_flight_fences) or_return
    defer if !ok do vk_impl.destroy_fences(&state, &in_flight_fences)

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
    defer vk_impl.destroy_image_views(&state, &state.image_views)
    defer vk.DestroyRenderPass(device, render_pass, nil)
    defer vk.DestroyPipelineLayout(device, pipeline_layout, nil)
    defer vk.DestroyPipeline(device, pipeline, nil)
    defer vk_impl.destroy_framebuffers(&state, &framebuffers)
    defer vk.FreeCommandBuffers(device, command_pool, u32(len(command_buffers)), raw_data(command_buffers))
    defer vk_impl.destroy_semaphores(&state, &image_available_semaphores)
    defer vk_impl.destroy_semaphores(&state, &render_finished_semaphores)
    defer vk_impl.destroy_fences(&state, &in_flight_fences)

}


_cmd_draw_frame :: proc() {
    using state
    vk.WaitForFences(device, 1, &in_flight_fences[flight_frame], true, max(u64))

    target_image_index = 0
    res := vk.AcquireNextImageKHR(device, swapchain, max(u64), image_available_semaphores[flight_frame], {}, &target_image_index); if res != .SUCCESS {
        switch {
            case res == .ERROR_OUT_OF_DATE_KHR:
                fallthrough
            case res == .SUBOPTIMAL_KHR:
                log.info("Image out of date, recreating swapchain...")
                ok := vk_impl.recreate_swapchain(&state, &state.swapchain, &state.swapchain_details, &state.image_views, &state.framebuffers); if !ok {
                    log.fatal("Failed to recreate swapchain")
                }
            return
        }
    }
    
    vk.ResetFences(device, 1, &in_flight_fences[flight_frame])

    vk.ResetCommandBuffer(command_buffers[flight_frame], {})
    vk_impl.record_command_buffer(&state)
    vk_impl.submit_command_buffer(&state)
    vk_impl.present(&state)

    state.flight_frame = (state.flight_frame + 1) % u32(config.RENDERER_FRAMES_IN_FLIGHT)
}
