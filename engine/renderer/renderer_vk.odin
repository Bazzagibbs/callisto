//+build windows, linux, darwin
//+private
package callisto_engine_renderer

import "core:log"
import vk "vendor:vulkan"
import vk_impl "vulkan"
import "../window"
import "../../config"
import "vendor:glfw"

debug_messenger: vk.DebugUtilsMessengerEXT = {}
instance: vk.Instance = {}
physical_device: vk.PhysicalDevice = {}
device: vk.Device = {}
surface: vk.SurfaceKHR = {}

_init :: proc() -> (ok: bool) {
    log.debug("Initializing renderer: Vulkan")
    res: vk.Result
    
    // Load procs required for instance creation
    vk.load_proc_addresses(get_proc_address)

    required_extensions : [dynamic]cstring = {
        vk.KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME,
    }
    
    // when CALLISTO_DESKTOP { 
        // Add extensions required by glfw
        window_exts := window.get_required_vk_extensions()
        append(&required_extensions, ..window_exts)
    //}

    // optional_extensions: [dynamic]cstring = {
        // vk.KHR_ACCELERATION_STRUCTURE_EXTENSION_NAME,
        // vk.KHR_RAY_TRACING_PIPELINE_EXTENSION_NAME,
        // vk.KHR_RAY_QUERY_EXTENSION_NAME,
        // vk.KHR_PIPELINE_LIBRARY_EXTENSION_NAME,
    // }

    app_info : vk.ApplicationInfo = {
        sType = vk.StructureType.APPLICATION_INFO,
        pApplicationName = cstring(config.App_Name),
        applicationVersion = vk.MAKE_VERSION(config.App_Version[0], config.App_Version[1], config.App_Version[2]),
        pEngineName = "Callisto",
        engineVersion = vk.MAKE_VERSION(config.Engine_Version[0], config.Engine_Version[1], config.Engine_Version[2]),
        apiVersion = vk.MAKE_VERSION(1, 1, 0),
    }

    

    // when VK_DEBUG {
    //}
    

    instance_info : vk.InstanceCreateInfo = {
        sType = vk.StructureType.INSTANCE_CREATE_INFO,
        pApplicationInfo = &app_info,
        flags = {.ENUMERATE_PORTABILITY_KHR},
        enabledExtensionCount = u32(len(required_extensions)),
        ppEnabledExtensionNames = &required_extensions[0],
        enabledLayerCount = 0,
    }
    
    // when VK_DEBUG {
        // debug_create_info := vk_impl.debug_messenger_create_info() 
        // instance_info.pNext = &debug_create_info
    // }

    // Vulkan instance
    res = vk.CreateInstance(&instance_info, nil, &instance); if res != .SUCCESS {
        log.fatal("Failed to create Vulkan instance:", res)
        ok = false
        return
    }
    defer if !ok do vk.DestroyInstance(instance, nil)

    
    // when VK_DEBUG {
        // debug_messenger = vk_impl.create_debug_messenger(instance, &debug_create_info) or_return
        // defer if !ok do vk_impl.destroy_debug_messenger(debug_messenger)
    // }
    
    // Instance has been created, other procs are now available
    vk.load_proc_addresses(get_proc_address)

    // Physical device
    // Logical device
    // Swapchain

    return true
}

_shutdown :: proc() {
    log.debug("Shutting down renderer")
    defer vk.DestroyInstance(instance, nil)
}

get_proc_address :: proc(proc_addr: rawptr, proc_name: cstring) {
    proc_temp := glfw.GetInstanceProcAddress(instance, proc_name)
    (cast(^rawptr)proc_addr)^ = glfw.GetInstanceProcAddress(instance, proc_name)
}