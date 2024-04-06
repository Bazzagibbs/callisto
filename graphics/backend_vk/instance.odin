package callisto_graphics_vulkan

import vk "vendor:vulkan"
import "core:log"
import "core:strings"
import "core:runtime"
import "../../config"
import "../../common"
import "../../platform"


// ==============================
VALIDATION_LAYERS :: []cstring {
    "VK_LAYER_KHRONOS_validation",
}

API_VERSION :: vk.API_VERSION_1_3

DEVICE_EXTS :: []cstring {
    vk.KHR_SWAPCHAIN_EXTENSION_NAME,
}

INSTANCE_EXTS :: []cstring {}

DEVICE_FEATURES :: vk.PhysicalDeviceFeatures {}
// ==============================


  //////////////
 // Instance //
//////////////

create_instance :: proc(r: ^Renderer_Impl, description: ^common.Engine_Description) -> (instance: vk.Instance, res: Result) {
    vk.load_proc_addresses(rawptr(platform.get_vk_proc_address))

    required_exts := make([dynamic]cstring)
    defer delete(required_exts)

    when ODIN_DEBUG {
        if check_validation_layer_support() == false {
            log.error("Validation layers not supported")
            res = .Initialization_Failed
            return
        }

        append(&required_exts, "VK_EXT_debug_utils")
    }

    platform_exts := platform.get_vk_required_extensions()
    defer {
        for str in platform_exts do delete(str)
        delete(platform_exts)
    }

    for ext in platform_exts {
        append(&required_exts, ext)
    }
    for ext in INSTANCE_EXTS {
        append(&required_exts, ext)
    }

    // APPLICATION INFO ======

    name_str   := strings.clone_to_cstring(description.application_description.name)
    engine_str := strings.clone_to_cstring(config.ENGINE_NAME)
    defer delete(name_str)
    defer delete(engine_str)

    ver   := description.application_description.version
    e_ver := config.ENGINE_VERSION

    application_info := vk.ApplicationInfo {
        sType              = .APPLICATION_INFO,
        pApplicationName   = name_str,
        applicationVersion = vk.MAKE_VERSION(ver.major, ver.minor, ver.patch),
        pEngineName        = engine_str,
        engineVersion      = vk.MAKE_VERSION(e_ver.major, e_ver.minor, e_ver.patch),
        apiVersion         = API_VERSION,
    }


    // INSTANCE CREATE =======
    instance_create_info := vk.InstanceCreateInfo {
        sType                   = .INSTANCE_CREATE_INFO,
        pApplicationInfo        = &application_info,
        enabledExtensionCount   = u32(len(required_exts)),
        ppEnabledExtensionNames = raw_data(required_exts),
    }

    when ODIN_DEBUG {
        r.logger = _create_vk_logger()
        debug_messenger_info := _debug_messenger_create_info(&r.logger)

        instance_create_info.enabledLayerCount = u32(len(VALIDATION_LAYERS))
        instance_create_info.ppEnabledLayerNames = raw_data(VALIDATION_LAYERS)
        
        when config.DEBUG_RENDERER_INIT {
            // This can be very verbose, so turn it off with a flag if we don't need it
            instance_create_info.pNext = &debug_messenger_info
        }
    }

    vk_res := vk.CreateInstance(&instance_create_info, nil, &instance)
    check_result(vk_res) or_return

    vk.load_proc_addresses(instance)

    when ODIN_DEBUG {
        vk_res = vk.CreateDebugUtilsMessengerEXT(instance, &debug_messenger_info, nil, &r.debug_messenger)
        check_result(vk_res)
    }

    return instance, .Ok
}


destroy_instance :: proc(r: ^Renderer_Impl, instance: vk.Instance) {
    when ODIN_DEBUG {
        vk.DestroyDebugUtilsMessengerEXT(r.instance, r.debug_messenger, nil)
        log.destroy_console_logger(r.logger)
    }

    vk.DestroyInstance(instance, nil)
}


check_validation_layer_support :: proc() -> bool {
    layer_count: u32
    vk.EnumerateInstanceLayerProperties(&layer_count, nil)

    available_layers := make([]vk.LayerProperties, layer_count)
    defer delete(available_layers)
    vk.EnumerateInstanceLayerProperties(&layer_count, raw_data(available_layers))

    available_layer_names := make([]cstring, layer_count)
    defer delete(available_layer_names)
    for &layer, i in available_layers {
        available_layer_names[i] = transmute(cstring)&(layer.layerName)
    }

    outer: 
    for requested_layer in VALIDATION_LAYERS {
        for avail_layer in available_layer_names {
            if runtime.cstring_cmp(avail_layer, requested_layer) == 0 {
                continue outer
            }
        }

        return false
    }

    return true
}

// =========================================================================================


  ///////////////
 //  Surface  //
///////////////

create_surface :: proc(r: ^Renderer_Impl, window: common.Window) -> (surface: vk.SurfaceKHR, res: Result) {
    vk_res: vk.Result
    surface, vk_res = platform.create_vk_window_surface(r.instance, window)
    return surface, check_result(vk_res)
}


destroy_surface :: proc(r: ^Renderer_Impl, surface: vk.SurfaceKHR) {
    vk.DestroySurfaceKHR(r.instance, surface, nil)
}

// =========================================================================================


  /////////////////////
 // Physical Device //
/////////////////////

select_physical_device :: proc(r: ^Renderer_Impl) -> (phys_device: vk.PhysicalDevice, phys_device_props: vk.PhysicalDeviceProperties, res: Result) {
    phys_device_count: u32
    vk_res := vk.EnumeratePhysicalDevices(r.instance, &phys_device_count, nil)
    check_result(res) or_return

    phys_devices := make([]vk.PhysicalDevice, phys_device_count)
    defer delete(phys_devices)
    vk_res = vk.EnumeratePhysicalDevices(r.instance, &phys_device_count, raw_data(phys_devices))
    check_result(res) or_return


    for phys_device in phys_devices[:phys_device_count] {
        if is_physical_device_suitable(r, phys_device) {
            vk.GetPhysicalDeviceProperties(phys_device, &phys_device_props)
            return phys_device, phys_device_props, .Ok
        }
    }

    log.error("No suitable physical devices")
    return {}, {}, .Device_Not_Supported
}

Queue_Family_Query :: struct {
    has_compute  : bool,
    has_graphics : bool,
    has_transfer : bool,
                 
    compute      : u32,
    graphics     : u32,
    transfer     : u32,
}


is_physical_device_suitable :: proc(r: ^Renderer_Impl, phys_device: vk.PhysicalDevice) -> (ok: bool) {
    props: vk.PhysicalDeviceProperties
    feats: vk.PhysicalDeviceFeatures
    vk.GetPhysicalDeviceProperties(phys_device, &props)
    vk.GetPhysicalDeviceFeatures(phys_device, &feats)

    families := find_queue_families(phys_device)
    families_adequate := is_family_complete(&families)

    swap_details := query_swapchain_support(phys_device, r.surface)
    defer delete_swapchain_support(&swap_details)
    swap_adequate := len(swap_details.formats) > 0 && len(swap_details.present_modes) > 0

    suitable := check_device_extension_support(phys_device, DEVICE_EXTS) &&
                families_adequate &&
                swap_adequate &&
                props.apiVersion >= API_VERSION

    when !config.RENDERER_HEADLESS {
        suitable &= (props.deviceType == .DISCRETE_GPU)
    }

    return suitable
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
            if transmute(cstring)&(avail_ext.extensionName) == req_ext {
                continue outer
            }
        }
        return false
    }

    return true
}

find_queue_families :: proc(phys_device: vk.PhysicalDevice) -> Queue_Family_Query {
    queue_family_count: u32
    vk.GetPhysicalDeviceQueueFamilyProperties(phys_device, &queue_family_count, nil)
    
    queue_family_props := make([]vk.QueueFamilyProperties, queue_family_count)
    defer delete(queue_family_props)
    vk.GetPhysicalDeviceQueueFamilyProperties(phys_device, &queue_family_count, raw_data(queue_family_props))

    families: Queue_Family_Query

    for family, i in queue_family_props {
        if .GRAPHICS in family.queueFlags {
            families.has_graphics = true
            families.graphics = u32(i)
        }
        if .COMPUTE in family.queueFlags {
            families.has_compute = true
            families.compute = u32(i)
        }
        if .TRANSFER in family.queueFlags {
            families.has_transfer = true
            families.transfer = u32(i)
        }

        if is_family_complete(&families) {
            break
        }
    }

    return families
}


is_family_complete :: proc(families: ^Queue_Family_Query) -> bool {
    is_complete :=  families.has_compute && 
                    families.has_transfer

    when !config.RENDERER_HEADLESS {
        is_complete &= families.has_graphics
    }

    return is_complete
}


Swapchain_Support_Details :: struct {
    capabilities:   vk.SurfaceCapabilitiesKHR,
    formats:        []vk.SurfaceFormatKHR,
    present_modes:  []vk.PresentModeKHR,
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

// =========================================================================================


  ////////////
 // Device //
////////////

create_device :: proc(r: ^Renderer_Impl, desc: ^common.Engine_Description) -> (device: vk.Device, queues: Queues, res: Result) {
    family_query := find_queue_families(r.physical_device)

    queues = Queues {
        compute_family  = family_query.compute,
        graphics_family = family_query.graphics,
        transfer_family = family_query.transfer,
    }

    unique_family_idx_and_queue_counts:= make(map[u32]u32)
    defer delete(unique_family_idx_and_queue_counts)

    unique_family_idx_and_queue_counts[queues.compute_family]  += 1
    unique_family_idx_and_queue_counts[queues.transfer_family] += 1

    if !desc.renderer_description.headless {
        unique_family_idx_and_queue_counts[queues.graphics_family] += 1
    }

    queue_priorities := []f32 { 1, 1, 1, }

    queue_create_infos := make([dynamic]vk.DeviceQueueCreateInfo)
    defer delete(queue_create_infos)

    for fam_idx, queue_count in unique_family_idx_and_queue_counts {
        append(&queue_create_infos, vk.DeviceQueueCreateInfo{
            sType               = .DEVICE_QUEUE_CREATE_INFO,
            queueFamilyIndex    = fam_idx,
            queueCount          = queue_count,
            pQueuePriorities    = raw_data(queue_priorities),
        })
    }

    device_features     := DEVICE_FEATURES
    device_exts         := DEVICE_EXTS
    validation_layers   := VALIDATION_LAYERS

    device_create_info := vk.DeviceCreateInfo {
        sType                   = .DEVICE_CREATE_INFO,
        queueCreateInfoCount    = u32(len(queue_create_infos)),
        pQueueCreateInfos       = raw_data(queue_create_infos),
        pEnabledFeatures        = &device_features,
        enabledExtensionCount   = u32(len(device_exts)),
        ppEnabledExtensionNames = raw_data(device_exts),
    }

    when ODIN_DEBUG {
        device_create_info.enabledLayerCount   = u32(len(validation_layers))
        device_create_info.ppEnabledLayerNames = raw_data(validation_layers)
    }

    vk_res := vk.CreateDevice(r.physical_device, &device_create_info, nil, &device)
    check_result(vk_res) or_return

    unique_family_idx_and_queue_counts[queues.transfer_family] -= 1
    queue_idx := unique_family_idx_and_queue_counts[queues.transfer_family]
    vk.GetDeviceQueue(device, queues.transfer_family, queue_idx, &queues.transfer)
    
    unique_family_idx_and_queue_counts[queues.compute_family] -= 1
    queue_idx = unique_family_idx_and_queue_counts[queues.compute_family]
    vk.GetDeviceQueue(device, queues.compute_family, queue_idx, &queues.compute)
   
    if !desc.renderer_description.headless {
        unique_family_idx_and_queue_counts[queues.graphics_family] -= 1
        queue_idx = unique_family_idx_and_queue_counts[queues.graphics_family]
        vk.GetDeviceQueue(device, queues.graphics_family, queue_idx, &queues.graphics)
    }

    res = .Ok
    return 
}


destroy_device :: proc(r: ^Renderer_Impl, device: vk.Device) {
    vk.DestroyDevice(device, nil)
}

// =========================================================================================


  ///////////////////
 // Command Pools //
///////////////////

// Each frame in flight needs its own command pool
// create_command_pools :: proc(r: ^Renderer_Impl, pools: []^Command_Pools) -> (res: Result) {
//     pool_create_info := vk.CommandPoolCreateInfo {
//         sType = .COMMAND_POOL_CREATE_INFO,
//         flags = {.RESET_COMMAND_BUFFER},
//     }
//
//     for pool in pools {
//         
//     }
// }
