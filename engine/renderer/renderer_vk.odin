//+build windows, linux, darwin
//+private
package callisto_engine_renderer

import "core:log"
import vk "vendor:vulkan"
import vkb "vulkan/builder"
import "../window"
import "vendor:glfw"

debug_messenger: vk.DebugUtilsMessengerEXT = {}
instance: vk.Instance = {}
physical_device: vk.PhysicalDevice = {}
device: vk.Device = {}
surface: vk.SurfaceKHR = {}

_init :: proc() -> (ok: bool) {
    log.debug("Initializing renderer: Vulkan")
   
    
    // Add app info to default create info
    app_info := vkb.application_info()
    instance_info := vkb.instance_create_info()
    instance_info.pApplicationInfo = &app_info
    
    // when VK_DEBUG {
        debug_create_info := vkb.debug_messenger_create_info() 
        instance_info.pNext = &debug_create_info
    // }

    // Vulkan instance
    
    
    // when VK_DEBUG {
        debug_messenger = vkb.create_debug_messenger(instance, &debug_create_info) or_return
        defer if !ok do vkb.destroy_debug_messenger(debug_messenger)
    // }

    // Physical device
    // Logical device
    // Swapchain

    return true
}

_shutdown :: proc() {
    log.debug("Shutting down renderer")
    defer vk.DestroyInstance(instance, nil)
}

