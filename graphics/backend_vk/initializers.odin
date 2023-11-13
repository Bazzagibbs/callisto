package callisto_graphics_vkb

import vk "vendor:vulkan"
import cc "../../common"
import "core:strings"
import "core:slice"
import "core:log"
import "core:math"
import "../../config"
import "../../platform"

INSTANCE_EXTS :: []cstring {}

DEVICE_EXTS :: []cstring {
    vk.KHR_SWAPCHAIN_EXTENSION_NAME,
}

DEVICE_FEATURES :: vk.PhysicalDeviceFeatures {}

ENABLE_VALIDATION_LAYERS :: ODIN_DEBUG

// Helpers
// ///////

check_result :: proc(res: vk.Result, loc := #caller_location) -> (ok: bool) {
    if res != .SUCCESS {
        log.error(loc, "Renderer error:", res)
        return false
    }
    return true
}

// INSTANCE
// ////////

create_instance :: proc(cg_ctx: ^Graphics_Context) -> (ok: bool) {
    vk.load_proc_addresses(rawptr(platform.get_vk_proc_address))

    application_info := vk.ApplicationInfo {
        sType               = .APPLICATION_INFO,
        pApplicationName    = strings.unsafe_string_to_cstring(config.APP_NAME),
        applicationVersion  = vk.MAKE_VERSION(config.APP_VERSION.x, config.APP_VERSION.y, config.APP_VERSION.z),
        pEngineName         = strings.unsafe_string_to_cstring(config.ENGINE_NAME),
        engineVersion       = vk.MAKE_VERSION(config.ENGINE_VERSION.x, config.ENGINE_VERSION.y, config.ENGINE_VERSION.z),
        apiVersion          = vk.MAKE_VERSION(1, 3, 0),
    }

    validation_layers :: []cstring {
        "VK_LAYER_KHRONOS_validation",
    }

    required_extensions := make([dynamic]cstring)
    defer delete(required_extensions)
   
    when ENABLE_VALIDATION_LAYERS {
        append(&required_extensions, "VK_EXT_debug_utils")
    }

    req_extensions := platform.get_required_extensions()
    defer {
        for ext in req_extensions {
            delete(ext)
        }
        delete(req_extensions)
    }
    for ext in req_extensions {
        append(&required_extensions, ext)
    }

    for ext in INSTANCE_EXTS {
        append(&required_extensions, ext)
    }
    
    // when {.Raytracing} in config.RENDERER_FEATURES {
    //     append(&required_extensions, "VK_KHR_acceleration_structure")
    //     append(&required_extensions, "VK_KHR_ray_tracing_pipeline")
    //     append(&required_extensions, "VK_KHR_ray_query")
    //     append(&required_extensions, "VK_KHR_pipeline_library")
    //     append(&required_extensions, "VK_KHR_deferred_host_operations")
    // }
    
    instance_create_info := vk.InstanceCreateInfo {
        sType                   = .INSTANCE_CREATE_INFO,
        pApplicationInfo        = &application_info,
        enabledLayerCount       = ENABLE_VALIDATION_LAYERS ? u32(len(validation_layers)) : 0,
        ppEnabledLayerNames     = raw_data(validation_layers),
        enabledExtensionCount   = u32(len(required_extensions)),
        ppEnabledExtensionNames = raw_data(required_extensions),
    }

    when ODIN_DEBUG {
        cg_ctx.logger = _create_vk_logger()
        debug_create_info := _debug_messenger_create_info(&cg_ctx.logger)

        instance_create_info.pNext = &debug_create_info
    }

    res := vk.CreateInstance(&instance_create_info, nil, &cg_ctx.instance)
    check_result(res) or_return

    vk.load_proc_addresses(cg_ctx.instance)

    when ODIN_DEBUG {
        res = vk.CreateDebugUtilsMessengerEXT(cg_ctx.instance, &debug_create_info, nil, &cg_ctx.debug_messenger)
        check_result(res)
    }

    return true
}


destroy_instance :: proc(cg_ctx: ^Graphics_Context) {
    when ODIN_DEBUG {
        vk.DestroyDebugUtilsMessengerEXT(cg_ctx.instance, cg_ctx.debug_messenger, nil)
        log.destroy_console_logger(cg_ctx.logger)
    }

    vk.DestroyInstance(cg_ctx.instance, nil)
}


// SURFACE
// ///////

create_surface :: proc(cg_ctx: ^Graphics_Context, window_ctx: ^platform.Window_Context) -> (ok: bool) {
    res := platform.create_vk_window_surface(cg_ctx.instance, window_ctx.handle, nil, &cg_ctx.surface)
    return check_result(res)
}


destroy_surface :: proc(cg_ctx: ^Graphics_Context) {
    vk.DestroySurfaceKHR(cg_ctx.instance, cg_ctx.surface, nil)
}


// DEVICE
// //////

select_physical_device :: proc(cg_ctx: ^Graphics_Context) -> (ok: bool) {
    phys_device_count: u32
    res := vk.EnumeratePhysicalDevices(cg_ctx.instance, &phys_device_count, nil)
    check_result(res) or_return

    phys_devices := make([]vk.PhysicalDevice, phys_device_count)
    defer delete(phys_devices)
    res = vk.EnumeratePhysicalDevices(cg_ctx.instance, &phys_device_count, raw_data(phys_devices))
    check_result(res) or_return


    for phys_device in phys_devices[:phys_device_count] {
        if is_physical_device_suitable(cg_ctx, phys_device) {
            cg_ctx.physical_device = phys_device
            return true
        }
    }

    log.error("No suitable physical devices")
    return false
}


is_physical_device_suitable :: proc(cg_ctx: ^Graphics_Context, phys_device: vk.PhysicalDevice) -> (ok: bool) {
    props: vk.PhysicalDeviceProperties
    feats: vk.PhysicalDeviceFeatures
    vk.GetPhysicalDeviceProperties(phys_device, &props)
    vk.GetPhysicalDeviceFeatures(phys_device, &feats)

    families := find_queue_families(phys_device)
    families_adequate := families.has_compute && families.has_transfer
    // when !HEADLESS {
    families_adequate &= families.has_graphics
    // }

    swap_details := query_swapchain_support(phys_device, cg_ctx.surface)
    swap_adequate := len(swap_details.formats) > 0 && len(swap_details.present_modes) > 0

    return  check_device_extension_support(phys_device, DEVICE_EXTS) &&
            families_adequate &&
            swap_adequate &&
            props.deviceType == .DISCRETE_GPU && 
            props.apiVersion >= vk.MAKE_VERSION(1, 3, 0)
}


check_device_extension_support :: proc(phys_device: vk.PhysicalDevice, required_exts: []cstring) -> bool {
    avail_ext_count: u32
    vk.EnumerateDeviceExtensionProperties(phys_device, nil, &avail_ext_count, nil)
    
    avail_exts := make([]vk.ExtensionProperties, avail_ext_count)
    defer delete(avail_exts)
    vk.EnumerateDeviceExtensionProperties(phys_device, nil, &avail_ext_count, raw_data(avail_exts))

    outer: for req_ext in required_exts {
        for avail_ext in avail_exts {
            avail_ext := avail_ext
            if cstring(&(avail_ext.extensionName[0])) == req_ext {
                continue outer
            }
        }
        return false
    }

    return true
}


find_queue_families :: proc(phys_device: vk.PhysicalDevice) -> Queue_Families {
    queue_family_count: u32
    vk.GetPhysicalDeviceQueueFamilyProperties(phys_device, &queue_family_count, nil)
    
    queue_family_props := make([]vk.QueueFamilyProperties, queue_family_count)
    defer delete(queue_family_props)
    vk.GetPhysicalDeviceQueueFamilyProperties(phys_device, &queue_family_count, raw_data(queue_family_props))

    families: Queue_Families

    for family, i in queue_family_props {
        if .COMPUTE in family.queueFlags {
            families.has_compute = true
            families.compute = u32(i)
        }
        if .GRAPHICS in family.queueFlags {
            families.has_graphics = true
            families.graphics = u32(i)
        }
        if .TRANSFER in family.queueFlags {
            families.has_transfer = true
            families.transfer = u32(i)
        }
    }

    return families
}


create_device :: proc(cg_ctx: ^Graphics_Context) -> (ok: bool) {
    families := find_queue_families(cg_ctx.physical_device)

    queue_create_info := vk.DeviceQueueCreateInfo {
        sType = .DEVICE_QUEUE_CREATE_INFO,
        queueFamilyIndex = families.graphics,
        queueCount = 1,
    }

    device_features := DEVICE_FEATURES
    device_create_info := vk.DeviceCreateInfo {
        sType = .DEVICE_CREATE_INFO,
        queueCreateInfoCount = 1,
        pQueueCreateInfos = &queue_create_info,
        pEnabledFeatures = &device_features,
    }
}

destroy_device :: proc(cg_ctx: ^Graphics_Context) {

}

// SWAPCHAIN
// /////////
Swapchain_Support_Details :: struct {
    capabilities:   vk.SurfaceCapabilitiesKHR,
    formats:        []vk.SurfaceFormatKHR,
    present_modes:  []vk.PresentModeKHR,
}

create_swapchain :: proc(cg_ctx: ^Graphics_Context, window_ctx: ^platform.Window_Context, old_swapchain: vk.SwapchainKHR = {}) -> (ok: bool) {
    swapchain_support := query_swapchain_support(cg_ctx.physical_device, cg_ctx.surface)
    defer delete_swapchain_support(&swapchain_support)

    // select image format
    swap_surface_fmt := swapchain_support.formats[0]
    for available_fmt in swapchain_support.formats {
        if available_fmt.format == .B8G8R8A8_SRGB && available_fmt.colorSpace == .SRGB_NONLINEAR {
            swap_surface_fmt = available_fmt
            break
        }
    }

    // use mailbox present mode if availabe, otherwise FIFO
    swap_present_mode := vk.PresentModeKHR.FIFO
    for available_present_mode in swapchain_support.present_modes {
        if available_present_mode == .MAILBOX {
            swap_present_mode = available_present_mode
            break
        }
    }

    // set window extent
    swap_extent: vk.Extent2D
    if swapchain_support.capabilities.currentExtent.width != max(u32) {
        using swapchain_support.capabilities
        swap_extent = {currentExtent.width, currentExtent.height}
    } else {
        using swapchain_support.capabilities
        window_size := platform.get_framebuffer_size(window_ctx)
        swap_extent.width  = math.clamp(u32(window_size.x), minImageExtent.width, maxImageExtent.width)
        swap_extent.height = math.clamp(u32(window_size.y), minImageExtent.height, maxImageExtent.height)
    }

    // prefer triple buffered if supported, otherwise use as many swap images as we can
    image_count := math.clamp(3, swapchain_support.capabilities.minImageCount, swapchain_support.capabilities.maxImageCount)

    swap_create_info := vk.SwapchainCreateInfoKHR {
        sType               = .SWAPCHAIN_CREATE_INFO_KHR,
        surface             = cg_ctx.surface,
        minImageCount       = image_count,
        imageFormat         = swap_surface_fmt.format,
        imageColorSpace     = swap_surface_fmt.colorSpace,
        imageExtent         = swap_extent,
        imageArrayLayers    = 1,
        imageUsage          = {.COLOR_ATTACHMENT}, // use TRANSFER_DST if using an intermediate render target, e.g. post processing image
        imageSharingMode    = .EXCLUSIVE,
        preTransform        = swapchain_support.capabilities.currentTransform,
        presentMode         = swap_present_mode,
        clipped             = true,
        oldSwapchain        = old_swapchain,
    }

    // if graphics queue family != present queue family {
    //     swap_create_info.imageSharingMode = .CONCURRENT
    //     swap_create_info.queueFamilyIndexCount = 2
    //     swap_create_info.pQueueFamilyIndices = raw_data(queue_family_indices)
    // }
    
    res := vk.CreateSwapchainKHR(cg_ctx.device, &swap_create_info, nil, &cg_ctx.swapchain)
    check_result(res) or_return


    return true
}


destroy_swapchain :: proc(cg_ctx: ^Graphics_Context) {
    vk.DestroySwapchainKHR(cg_ctx.device, cg_ctx.swapchain, nil)
}


query_swapchain_support :: proc(phys_device: vk.PhysicalDevice, surface: vk.SurfaceKHR) -> Swapchain_Support_Details {
    details: Swapchain_Support_Details

    vk.GetPhysicalDeviceSurfaceCapabilitiesKHR(phys_device, surface, &details.capabilities)
    
    fmt_count: u32
    vk.GetPhysicalDeviceSurfaceFormatsKHR(phys_device, surface, &fmt_count, nil)
    details.formats = make([]vk.SurfaceFormatKHR, fmt_count)
    vk.GetPhysicalDeviceSurfaceFormatsKHR(phys_device, surface, &fmt_count, raw_data(details.formats))

    present_mode_count: u32
    vk.GetPhysicalDeviceSurfacePresentModesKHR(phys_device, surface, &present_mode_count, nil)
    details.present_modes = make([]vk.PresentModeKHR, present_mode_count)
    vk.GetPhysicalDeviceSurfacePresentModesKHR(phys_device, surface, &present_mode_count, raw_data(details.present_modes))

    return details
}


delete_swapchain_support :: proc(details: ^Swapchain_Support_Details) {
    delete(details.formats)
    delete(details.present_modes)
}
