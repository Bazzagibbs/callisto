package callisto_engine_renderer_vulkan

import "core:log"
import "core:strings"
import vk "vendor:vulkan"
import "../../../config"
when config.Build_Target == .Desktop do import "vendor:glfw"
import "../../window"


create_instance :: proc() -> (instance: vk.Instance, ok: bool) {
    required_extensions : [dynamic]cstring = {vk.KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME}
    res: vk.Result
    when config.Build_Target == .Desktop { 
        // Add extensions required by glfw
        vk.load_proc_addresses_custom(get_global_proc_address)
        
        window_exts := window.get_required_vk_extensions()
        append(&required_extensions, ..window_exts)
    }
    when config.Engine_Debug {
        append(&required_extensions, vk.EXT_DEBUG_UTILS_EXTENSION_NAME)
    }
    
    app_info : vk.ApplicationInfo = {
        sType = vk.StructureType.APPLICATION_INFO,
        pApplicationName = cstring(config.App_Name),
        applicationVersion = vk.MAKE_VERSION(config.App_Version[0], config.App_Version[1], config.App_Version[2]),
        pEngineName = "Callisto",
        engineVersion = vk.MAKE_VERSION(config.Engine_Version[0], config.Engine_Version[1], config.Engine_Version[2]),
        apiVersion = vk.MAKE_VERSION(1, 1, 0),
    }
    
    instance_info : vk.InstanceCreateInfo = {
        sType = vk.StructureType.INSTANCE_CREATE_INFO,
        pApplicationInfo = &app_info,
        flags = {.ENUMERATE_PORTABILITY_KHR},
        enabledExtensionCount = u32(len(required_extensions)),
        ppEnabledExtensionNames = raw_data(required_extensions[:]),
    }

    when config.Engine_Debug {
        init_logger()
        validation_layers := [?]cstring {
            "VK_LAYER_KHRONOS_validation",
        }
        if check_validation_layer_support(validation_layers[:]) == false {
            log.fatal("Requested Vulkan validation layer not available")
            return {}, false
        }

        // debug_create_info := vk_impl.debug_messenger_create_info() 
        // instance_info.pNext = &debug_create_info
        instance_info.enabledLayerCount = len(validation_layers)
        instance_info.ppEnabledLayerNames = raw_data(validation_layers[:])
    }
    
    // Vulkan instance
    res = vk.CreateInstance(&instance_info, nil, &instance); if res != .SUCCESS {
        log.fatal("Failed to create Vulkan instance:", res)
        return {}, false
    }
    defer if !ok do vk.DestroyInstance(instance, nil)
    
    // Instance has been created, other procs are now available
    vk.load_proc_addresses_instance(instance)

    return instance, true
}

create_debug_messenger :: proc(instance: vk.Instance) -> (messenger: vk.DebugUtilsMessengerEXT, ok: bool) {
    when config.Engine_Debug {
        // create debug messenger
        debug_create_info := debug_messenger_create_info() 
        res := vk.CreateDebugUtilsMessengerEXT(instance, &debug_create_info, nil, &messenger); if res != .SUCCESS {
            log.fatal("Error creating debug messenger:", res)
            return {}, false
        }
        defer if !ok do vk.DestroyDebugUtilsMessengerEXT(instance, messenger, nil)
    }
    return messenger, true
}

create_physical_device :: proc() -> (physical_device: vk.PhysicalDevice, ok: bool) {
    return {}, false
}

create_logical_device :: proc() -> (logical_device: vk.Device, ok: bool) {
    return {}, false
}

get_global_proc_address :: proc(p: rawptr, name: cstring) {
    (^rawptr)(p)^ = glfw.GetInstanceProcAddress(nil, name)
}

check_validation_layer_support :: proc(requested_layers: []cstring) -> bool {
    layer_count: u32
    vk.EnumerateInstanceLayerProperties(&layer_count, nil)
    layers := make([]vk.LayerProperties, layer_count)
    defer delete(layers)
    vk.EnumerateInstanceLayerProperties(&layer_count, raw_data(layers))

    outer: for layer in requested_layers {
        for available_layer in layers {
            available_name := available_layer.layerName
            if cstring(raw_data(available_name[:])) == layer do continue outer
        }
        return false
    }
    return true
}