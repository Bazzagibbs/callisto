//+build windows, linux, darwin
//+private
package callisto_engine_renderer

import "core:log"
import vk "vendor:vulkan"
import vk_impl "vulkan"
import "core:strings"

debug_messenger: vk.DebugUtilsMessengerEXT = {}
instance: vk.Instance = {}
physical_device: vk.PhysicalDevice = {}
device: vk.Device = {}
queues: vk_impl.Queue_Handles = {}
surface: vk.SurfaceKHR = {}


_init :: proc() -> (ok: bool) {
    log.info("Initializing renderer: Vulkan")
    instance = vk_impl.create_instance() or_return
    defer if !ok do vk.DestroyInstance(instance, nil)

    debug_messenger = vk_impl.create_debug_messenger(instance) or_return
    defer if !ok do vk.DestroyDebugUtilsMessengerEXT(instance, debug_messenger, nil)

    physical_device = vk_impl.select_physical_device(instance) or_return
    
    device, queues = vk_impl.create_logical_device(physical_device) or_return
    defer if !ok do vk.DestroyDevice(device, nil)

    // Surface
    // Swapchain
    // Image views

    return true
}

_shutdown :: proc() {
    log.info("Shutting down renderer")
    defer vk.DestroyInstance(instance, nil)
    defer vk.DestroyDebugUtilsMessengerEXT(instance, debug_messenger, nil)
    defer vk.DestroyDevice(device, nil)
}
