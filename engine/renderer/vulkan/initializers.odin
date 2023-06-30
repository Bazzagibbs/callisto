package callisto_engine_renderer_vulkan

import "core:log"
import "core:strings"
import "core:math"
import vk "vendor:vulkan"
import "../../../config"
when config.Build_Target == .Desktop do import "vendor:glfw"
import "../../window"

Queue_Family_Indices :: struct {
    graphics: Maybe(u32),
    present: Maybe(u32),
}

Queue_Handles :: struct {
    graphics: vk.Queue,
    present: vk.Queue,
}

Swapchain_Details :: struct {
    capabilities: vk.SurfaceCapabilitiesKHR,
    format: vk.SurfaceFormatKHR,
    present_mode: vk.PresentModeKHR,
    swap_extent: vk.Extent2D,
}

validation_layers := [?]cstring {
    "VK_LAYER_KHRONOS_validation",
}

required_instance_extensions : [dynamic]cstring = {
    vk.KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME,
}

required_device_extensions : [dynamic]cstring = {
    vk.KHR_SWAPCHAIN_EXTENSION_NAME,
}

get_global_proc_address :: proc(p: rawptr, name: cstring) {
    when config.Build_Target == .Desktop {
        (^rawptr)(p)^ = glfw.GetInstanceProcAddress(nil, name)
    }
}

create_instance :: proc() -> (instance: vk.Instance, ok: bool) {
    res: vk.Result
    when config.Build_Target == .Desktop { 
        // Add extensions required by glfw
        vk.load_proc_addresses_custom(get_global_proc_address)
        
        window_exts := window.get_required_vk_extensions()
        append(&required_instance_extensions, ..window_exts)
    }
    when config.Engine_Debug {
        append(&required_instance_extensions, vk.EXT_DEBUG_UTILS_EXTENSION_NAME)
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
        enabledExtensionCount = u32(len(required_instance_extensions)),
        ppEnabledExtensionNames = raw_data(required_instance_extensions),
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

create_surface :: proc(instance: vk.Instance) -> (surface: vk.SurfaceKHR, ok: bool) {
    when config.Build_Target == .Desktop {
        res := glfw.CreateWindowSurface(instance, glfw.WindowHandle(window.handle), nil, &surface); if res != .SUCCESS {
            log.fatal("Failed to create window surface:", res)
            return {}, false
        }
        ok = true
        return
    }

    log.fatal("Platform not supported:", config.Build_Target)
    return {}, false
}

select_physical_device :: proc(instance: vk.Instance, surface: vk.SurfaceKHR) -> (physical_device: vk.PhysicalDevice, ok: bool) {
    // TODO: Also allow user to specify desired GPU in graphics settings
    device_count: u32
    vk.EnumeratePhysicalDevices(instance, &device_count, nil)
    devices := make([]vk.PhysicalDevice, device_count)
    defer delete(devices)
    vk.EnumeratePhysicalDevices(instance, &device_count, raw_data(devices))

    highest_device: vk.PhysicalDevice = {}
    highest_score := -1
    for device in devices[:device_count] {
        score := rank_physical_device(device, surface)
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

rank_physical_device :: proc(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR) -> (score: int) {    
    props: vk.PhysicalDeviceProperties
    features: vk.PhysicalDeviceFeatures
    vk.GetPhysicalDeviceProperties(physical_device, &props)
    vk.GetPhysicalDeviceFeatures(physical_device, &features)
    
    defer when config.Engine_Debug {
        log.info(cstring(raw_data(props.deviceName[:])), "Score:", score)
    }

    if is_physical_device_suitable(physical_device, surface) == false do return -1
    if features.geometryShader == false do return -1
    if props.deviceType == .DISCRETE_GPU do score += 1000
    score += int(props.limits.maxImageDimension2D)
    

    return
}

is_physical_device_suitable :: proc(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR) -> bool {
    families := find_queue_family_indices(physical_device, surface)
    ok := is_queue_families_complete(&families)
    ok &= check_device_extension_support(physical_device)
    return ok
}

find_queue_family_indices :: proc(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR) -> (indices: Queue_Family_Indices) {
    family_count: u32
    vk.GetPhysicalDeviceQueueFamilyProperties(physical_device, &family_count, nil)
    families := make([]vk.QueueFamilyProperties, family_count)
    defer delete(families)
    vk.GetPhysicalDeviceQueueFamilyProperties(physical_device, &family_count, raw_data(families))


    for family, i in families {
        // Graphics
        if .GRAPHICS in family.queueFlags {
            indices.graphics = u32(i)
        }
       
        // Present
        present_support: b32 = false
        vk.GetPhysicalDeviceSurfaceSupportKHR(physical_device, u32(i), surface, &present_support)
        if present_support {
            indices.present = u32(i)
        }

        
        if is_queue_families_complete(&indices) do break
    }

    return
}

is_queue_families_complete :: proc(indices: ^Queue_Family_Indices) -> (is_complete: bool) {
    _ = indices.graphics.? or_return
    _ = indices.present.? or_return
    
    return true
}

create_logical_device :: proc(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR) -> (logical_device: vk.Device, queues: Queue_Handles, ok: bool) {
    indices := find_queue_family_indices(physical_device, surface)

    // Queue families may have the same index. Only create one queue in this case.
    unique_indices_set := make(map[u32]struct{})
    defer delete(unique_indices_set)
    queue_create_infos := make([dynamic]vk.DeviceQueueCreateInfo)
    defer delete(queue_create_infos)

    unique_indices_set[indices.graphics.?] = {}
    unique_indices_set[indices.present.?] = {}
    
    queue_priority: f32 = 1.0
    for index in unique_indices_set {
        append(&queue_create_infos, default_queue_create_info(index, &queue_priority))
    }


    features: vk.PhysicalDeviceFeatures = {}

    device_create_info: vk.DeviceCreateInfo = {
        sType = .DEVICE_CREATE_INFO,
        queueCreateInfoCount = u32(len(queue_create_infos)),
        pQueueCreateInfos = raw_data(queue_create_infos),
        pEnabledFeatures = &features,
        enabledExtensionCount = u32(len(required_device_extensions)),
        ppEnabledExtensionNames = raw_data(required_device_extensions),
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
    vk.GetDeviceQueue(logical_device, indices.present.?, 0, &queues.present)
    ok = true
    return 
}

default_queue_create_info :: proc(queue_family_index: u32, priority: ^f32) -> (info: vk.DeviceQueueCreateInfo) {

    info.sType = .DEVICE_QUEUE_CREATE_INFO
    info.queueCount = 1
    info.queueFamilyIndex = queue_family_index
    info.pQueuePriorities = priority
    return
}

check_device_extension_support :: proc(physical_device: vk.PhysicalDevice) -> (ok: bool) {
    extension_count: u32
    vk.EnumerateDeviceExtensionProperties(physical_device, nil, &extension_count, nil)
    extension_props := make([]vk.ExtensionProperties, extension_count)
    defer delete(extension_props)
    vk.EnumerateDeviceExtensionProperties(physical_device, nil, &extension_count, raw_data(extension_props[:]))

    outer: for required_ext in required_device_extensions {
        for available_ext in extension_props {
            ext_name := available_ext.extensionName
            ext_name_cstring := cstring(raw_data(ext_name[:]))

            if ext_name_cstring == required_ext {
                continue outer
            }
        }
        return false
    }

    return true
}

create_swapchain :: proc(physical_device: vk.PhysicalDevice, device: vk.Device, surface: vk.SurfaceKHR) -> (swapchain: vk.SwapchainKHR, details: Swapchain_Details, ok: bool) {
    details, ok = select_swapchain_details(physical_device, surface); if !ok {
        log.fatal("Swapchain is not suitable")
    }

    image_count: u32 = details.capabilities.minImageCount + 1

    if details.capabilities.maxImageCount > 0 && image_count > details.capabilities.maxImageCount {
        image_count = details.capabilities.maxImageCount
    }    

    
    swapchain_create_info: vk.SwapchainCreateInfoKHR = {
        sType = .SWAPCHAIN_CREATE_INFO_KHR,
        surface = surface,
        minImageCount = image_count,
        imageFormat = details.format.format,
        imageColorSpace = details.format.colorSpace,
        imageExtent = details.swap_extent,
        imageArrayLayers = 1, // Change if using stereo rendering
        imageUsage = {.COLOR_ATTACHMENT},
        preTransform = details.capabilities.currentTransform,
        compositeAlpha = {.OPAQUE},
        presentMode = details.present_mode,
        clipped = true,
    }
    
    indices := find_queue_family_indices(physical_device, surface)
    indices_values := [?]u32 {indices.graphics.?, indices.present.?}    
    if indices.graphics.? == indices.present.? {
        swapchain_create_info.imageSharingMode = .EXCLUSIVE
        swapchain_create_info.queueFamilyIndexCount = 2
        swapchain_create_info.pQueueFamilyIndices = raw_data(indices_values[:])
    }
    else {
        swapchain_create_info.imageSharingMode = .CONCURRENT
    }

    res := vk.CreateSwapchainKHR(device, &swapchain_create_info, nil, &swapchain); if res != .SUCCESS {
        log.fatal("Failed to create swapchain:", res)
        return {}, {}, false
    }

    ok = true
    return
}

select_swapchain_details :: proc(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR) -> (details: Swapchain_Details, ok: bool) {
    vk.GetPhysicalDeviceSurfaceCapabilitiesKHR(physical_device, surface, &details.capabilities)
    
    format_count: u32
    vk.GetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &format_count, nil)
    formats := make([]vk.SurfaceFormatKHR, format_count)
    defer delete(formats)
    vk.GetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &format_count, raw_data(formats))

    present_mode_count: u32
    vk.GetPhysicalDeviceSurfacePresentModesKHR(physical_device, surface, &present_mode_count, nil)
    present_modes := make([]vk.PresentModeKHR, present_mode_count)
    defer delete(present_modes)
    vk.GetPhysicalDeviceSurfacePresentModesKHR(physical_device, surface, &present_mode_count, raw_data(present_modes))

    ok = len(formats) > 0 && len(present_modes) > 0

    details.format = select_swapchain_format(formats[:])
    details.present_mode = select_swapchain_present_mode(present_modes[:])
    details.swap_extent = select_swapchain_extent(&details.capabilities)

    return
}

select_swapchain_format :: proc(available_formats: []vk.SurfaceFormatKHR) -> vk.SurfaceFormatKHR {
    for format in available_formats {
        if format.format == .B8G8R8A8_SRGB && format.colorSpace == .SRGB_NONLINEAR {
            return format
        }
    }
    return available_formats[0]
}

select_swapchain_present_mode :: proc(available_present_modes: []vk.PresentModeKHR) -> vk.PresentModeKHR {
    for mode in available_present_modes {
        if mode == .MAILBOX {
            return mode
        }
    }
    return .FIFO
}

select_swapchain_extent :: proc(surface_capabilities: ^vk.SurfaceCapabilitiesKHR) -> (extent: vk.Extent2D) {
    if surface_capabilities.currentExtent.width != max(u32) {
        return surface_capabilities.currentExtent
    }

    when config.Build_Target == .Desktop {
        s_width, s_height:= glfw.GetFramebufferSize(glfw.WindowHandle(window.handle))
        width := u32(s_width)
        height := u32(s_height)
        extent.width = math.clamp(width, surface_capabilities.minImageExtent.width, surface_capabilities.maxImageExtent.width)
        extent.height = math.clamp(height, surface_capabilities.minImageExtent.height, surface_capabilities.maxImageExtent.height)
        return
    }
    
    log.error("Build target not supported")
    return surface_capabilities.currentExtent
}

get_swapchain_images :: proc(device: vk.Device, swapchain: vk.SwapchainKHR, images: ^[dynamic]vk.Image) {
    image_count: u32
    vk.GetSwapchainImagesKHR(device, swapchain, &image_count, nil)
    resize(images, int(image_count))
    vk.GetSwapchainImagesKHR(device, swapchain, &image_count, raw_data(images^))
}