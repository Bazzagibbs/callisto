//+build windows, linux, darwin
//+private
package callisto_graphics

import "core:log"
import vk "vendor:vulkan"
import "core:strings"
import "../config"

// Ownership, may support multiple vk instances later.
main_state: State = {}
bound_state: ^State

_impl_init :: proc() -> (ok: bool) {
    bound_state = &main_state
    using bound_state

    log.info("Initializing renderer: Vulkan")

    _create_instance(&instance) or_return
    defer if !ok do vk.DestroyInstance(instance, nil)
 
    // First "state" pointer is always const. Explicitly pass pointers to mutable data in separate params
    _create_debug_messenger(&debug_messenger) or_return
    defer if !ok do vk.DestroyDebugUtilsMessengerEXT(instance, debug_messenger, nil)
    
    _create_surface(&surface) or_return
    defer if !ok do vk.DestroySurfaceKHR(instance, surface, nil)

    _select_physical_device(&physical_device) or_return
    
    _create_logical_device(&device, &queue_family_indices, &queues) or_return
    defer if !ok do vk.DestroyDevice(device, nil)
    
    _create_command_pool(&command_pool) or_return
    defer if !ok do vk.DestroyCommandPool(device, command_pool, nil)

    _create_command_buffers(config.RENDERER_FRAMES_IN_FLIGHT, &command_buffers) or_return
    defer if !ok do vk.FreeCommandBuffers(device, command_pool, u32(len(command_buffers)), raw_data(command_buffers))

    _create_semaphores(config.RENDERER_FRAMES_IN_FLIGHT, &image_available_semaphores) or_return
    defer if !ok do _destroy_semaphores(image_available_semaphores)
    _create_semaphores(config.RENDERER_FRAMES_IN_FLIGHT, &render_finished_semaphores) or_return
    defer if !ok do _destroy_semaphores(render_finished_semaphores)
    _create_fences(config.RENDERER_FRAMES_IN_FLIGHT, &in_flight_fences) or_return
    defer if !ok do _destroy_fences(in_flight_fences)

    _create_swapchain(&swapchain, &swapchain_details) or_return
    defer if !ok do vk.DestroySwapchainKHR(device, swapchain, nil)

    _get_images(&images)

    _create_image_views(&image_views) or_return
    defer if !ok do _destroy_image_views(image_views)
    
    _create_depth_image(&depth_image, &depth_image_memory, &depth_image_view) or_return
    defer if !ok do _destroy_depth_image(depth_image, depth_image_memory, depth_image_view)

    _create_render_pass(&render_pass) or_return
    defer if !ok do vk.DestroyRenderPass(device, render_pass, nil)

    _create_framebuffers(&framebuffers) or_return
    defer if !ok do _destroy_framebuffers(framebuffers)

    _create_descriptor_pool(&descriptor_pool) or_return
    defer if !ok do vk.DestroyDescriptorPool(device, descriptor_pool, nil)

    _create_texture_sampler(&texture_sampler_default) or_return
    defer if !ok do _destroy_texture_sampler(texture_sampler_default)

    return true
}

_impl_shutdown :: proc() {
    log.info("Shutting down renderer")
    using bound_state

    vk.DeviceWaitIdle(device)
    // TODO: Move these out of global scope
    defer delete(required_instance_extensions)
    defer delete(required_device_extensions)
    defer delete(dynamic_states)
    // ====================================

    defer _destroy_state(bound_state)
    defer vk.DestroyInstance(instance, nil)
    defer _destroy_logger(logger)
    defer vk.DestroyDebugUtilsMessengerEXT(instance, debug_messenger, nil)
    defer vk.DestroySurfaceKHR(instance, surface, nil)
    defer vk.DestroyDevice(device, nil)
    defer vk.DestroyCommandPool(device, command_pool, nil)
    defer vk.FreeCommandBuffers(device, command_pool, u32(len(command_buffers)), raw_data(command_buffers))
    defer _destroy_semaphores(image_available_semaphores)
    defer _destroy_semaphores(render_finished_semaphores)
    defer _destroy_fences(in_flight_fences)
    defer vk.DestroySwapchainKHR(device, swapchain, nil)
    defer _destroy_image_views(image_views)
    defer vk.DestroyRenderPass(device, render_pass, nil)
    defer _destroy_framebuffers(framebuffers)
    defer vk.DestroyDescriptorPool(device, descriptor_pool, nil)
    defer _destroy_texture_sampler(texture_sampler_default)
    defer _destroy_depth_image(depth_image, depth_image_memory, depth_image_view)
}

_impl_wait_until_idle :: proc() {
    vk.DeviceWaitIdle(bound_state.device)
}
