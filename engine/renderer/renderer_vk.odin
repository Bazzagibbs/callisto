//+build windows, linux, darwin
//+private
package callisto_engine_renderer

import "core:log"
import vk "vendor:vulkan"
import vk_impl "vulkan"
import "core:strings"

debug_messenger: vk.DebugUtilsMessengerEXT = {}
instance: vk.Instance = {}
surface: vk.SurfaceKHR = {}
physical_device: vk.PhysicalDevice = {}
device: vk.Device = {}
queues: vk_impl.Queue_Handles = {}
swapchain: vk.SwapchainKHR = {}
swapchain_images: [dynamic]vk.Image = {}
swapchain_details: vk_impl.Swapchain_Details = {}

_init :: proc() -> (ok: bool) {
    log.info("Initializing renderer: Vulkan")
    instance = vk_impl.create_instance() or_return
    defer if !ok do vk.DestroyInstance(instance, nil)

    debug_messenger = vk_impl.create_debug_messenger(instance) or_return
    defer if !ok do vk.DestroyDebugUtilsMessengerEXT(instance, debug_messenger, nil)
    
    surface = vk_impl.create_surface(instance) or_return
    defer if !ok do vk.DestroySurfaceKHR(instance, surface, nil)

    physical_device = vk_impl.select_physical_device(instance, surface) or_return
    
    device, queues = vk_impl.create_logical_device(physical_device, surface) or_return
    defer if !ok do vk.DestroyDevice(device, nil)

    swapchain, swapchain_details = vk_impl.create_swapchain(physical_device, device, surface) or_return
    defer if !ok do vk.DestroySwapchainKHR(device, swapchain, nil)

    // Images
    vk_impl.get_swapchain_images(device, swapchain, &swapchain_images)

    // Image views

    return true
}

_shutdown :: proc() {
    log.info("Shutting down renderer")
    defer vk.DestroyInstance(instance, nil)
    defer vk.DestroyDebugUtilsMessengerEXT(instance, debug_messenger, nil)
    defer vk.DestroySurfaceKHR(instance, surface, nil)
    defer vk.DestroyDevice(device, nil)
    defer vk.DestroySwapchainKHR(device, swapchain, nil)
}
