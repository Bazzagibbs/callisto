package callisto_engine_renderer_vulkan

import "core:log"
import "core:strings"
import vk "vendor:vulkan"
import "../../../config"
when config.Build_Target == .Desktop do import "vendor:glfw"
import "../../window"

Queue_Family_Indices :: struct {
    graphics: Maybe(u32),
}

Queue_Handles :: struct {
    graphics: vk.Queue,
}

validation_layers := [?]cstring {
    "VK_LAYER_KHRONOS_validation",
}

get_global_proc_address :: proc(p: rawptr, name: cstring) {
    when config.Build_Target == .Desktop {
        (^rawptr)(p)^ = glfw.GetInstanceProcAddress(nil, name)
    }
}

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

select_physical_device :: proc(instance: vk.Instance) -> (physical_device: vk.PhysicalDevice, ok: bool) {
    // TODO: Also allow user to specify desired GPU in graphics settings
    device_count: u32
    vk.EnumeratePhysicalDevices(instance, &device_count, nil)
    devices := make([]vk.PhysicalDevice, device_count)
    defer delete(devices)
    vk.EnumeratePhysicalDevices(instance, &device_count, raw_data(devices))

    highest_device: vk.PhysicalDevice = {}
    highest_score := -1
    for device in devices[:device_count] {
        score := rank_physical_device(device)
        if score > highest_score {
            highest_score = score
            highest_device = device
        }
    }

    if highest_score < 0 {
        log.fatal("No suitable physical devices available")
        return {}, false
    }
    

    return highest_device, true
}

rank_physical_device :: proc(physical_device: vk.PhysicalDevice) -> (score: int) {    
    props: vk.PhysicalDeviceProperties
    features: vk.PhysicalDeviceFeatures
    vk.GetPhysicalDeviceProperties(physical_device, &props)
    vk.GetPhysicalDeviceFeatures(physical_device, &features)
    
    defer when config.Engine_Debug {
        log.info(cstring(raw_data(props.deviceName[:])), "Score:", score)
    }

    if is_physical_device_suitable(physical_device) == false do return -1
    if features.geometryShader == false do return -1
    if props.deviceType == .DISCRETE_GPU do score += 1000
    score += int(props.limits.maxImageDimension2D)
    

    return
}

is_physical_device_suitable :: proc(physical_device: vk.PhysicalDevice) -> bool {
    families := find_queue_family_indices(physical_device)
    ok := is_queue_families_complete(&families)

    return ok
}

find_queue_family_indices :: proc(physical_device: vk.PhysicalDevice) -> (indices: Queue_Family_Indices) {
    family_count: u32
    vk.GetPhysicalDeviceQueueFamilyProperties(physical_device, &family_count, nil)
    families := make([]vk.QueueFamilyProperties, family_count)
    defer delete(families)
    vk.GetPhysicalDeviceQueueFamilyProperties(physical_device, &family_count, raw_data(families))

    for family, i in families {
        if .GRAPHICS in family.queueFlags {
            indices.graphics = u32(i)
        }
        
        if is_queue_families_complete(&indices) do break
    }

    return
}

is_queue_families_complete :: proc(indices: ^Queue_Family_Indices) -> bool {
    _, ok := indices.graphics.?
    return ok
}

create_logical_device :: proc(physical_device: vk.PhysicalDevice) -> (logical_device: vk.Device, queues: Queue_Handles, ok: bool) {
    indices := find_queue_family_indices(physical_device)
    queue_priority := [?]f32 {1.0,}

    queue_create_info: vk.DeviceQueueCreateInfo = {
        sType = .DEVICE_QUEUE_CREATE_INFO,
        queueCount = 1,
        queueFamilyIndex = indices.graphics.?,
        pQueuePriorities = raw_data(queue_priority[:])
    }

    features: vk.PhysicalDeviceFeatures = {}

    device_create_info: vk.DeviceCreateInfo = {
        sType = .DEVICE_CREATE_INFO,
        queueCreateInfoCount = 1,
        pQueueCreateInfos = &queue_create_info,
        pEnabledFeatures = &features,
    } 

    when config.Engine_Debug {
        device_create_info.enabledLayerCount = len(validation_layers)
        device_create_info.ppEnabledLayerNames = raw_data(validation_layers[:])
    }

    res := vk.CreateDevice(physical_device, &device_create_info, nil, &logical_device); if res != .SUCCESS {
        log.fatal("Failed to create logical device:", res)
        return {}, {}, false
    }

    vk.GetDeviceQueue(logical_device, indices.graphics.?, 0, &queues.graphics)
    ok = true
    return 
}

