//+build windows, linux, darwin
//+private
package callisto_engine_renderer

import "core:log"
import vk "vendor:vulkan"
import vk_impl "vulkan"
import "../window"
import "../../config"
import "vendor:glfw"
import "core:strings"

debug_messenger: vk.DebugUtilsMessengerEXT = {}
instance: vk.Instance = {}
physical_device: vk.PhysicalDevice = {}
device: vk.Device = {}
surface: vk.SurfaceKHR = {}

_init :: proc() -> (ok: bool) {
    log.info("Initializing renderer: Vulkan")
    instance = vk_impl.create_instance() or_return
    defer if !ok do vk.DestroyInstance(instance, nil)

    debug_messenger = vk_impl.create_debug_messenger(instance) or_return
    defer if !ok do vk.DestroyDebugUtilsMessengerEXT(instance, debug_messenger, nil)

    // Physical device
    
    // Logical device
    
    // Swapchain

    return true
}

_shutdown :: proc() {
    log.info("Shutting down renderer")
    defer vk.DestroyInstance(instance, nil)
    defer vk.DestroyDebugUtilsMessengerEXT(instance, debug_messenger, nil)
}
