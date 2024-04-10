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

SYNC_FEATURES_2 :: vk.PhysicalDeviceSynchronization2Features {
    sType            = .PHYSICAL_DEVICE_SYNCHRONIZATION_2_FEATURES,
    synchronization2 = true,
}
// ==============================


  //////////////
 // Instance //
//////////////

instance_create :: proc(r: ^Renderer_Impl, description: ^common.Engine_Description) -> (res: Result) {
    vk.load_proc_addresses(rawptr(platform.get_vk_proc_address))

    required_exts := make([dynamic]cstring)
    defer delete(required_exts)

    when ODIN_DEBUG {
        if _check_validation_layer_support() == false {
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

    vk_res := vk.CreateInstance(&instance_create_info, nil, &r.instance)
    check_result(vk_res) or_return

    vk.load_proc_addresses(r.instance)

    when ODIN_DEBUG {
        vk_res = vk.CreateDebugUtilsMessengerEXT(r.instance, &debug_messenger_info, nil, &r.debug_messenger)
        check_result(vk_res)
    }

    return .Ok
}


instance_destroy :: proc(r: ^Renderer_Impl) {
    when ODIN_DEBUG {
        vk.DestroyDebugUtilsMessengerEXT(r.instance, r.debug_messenger, nil)
        log.destroy_console_logger(r.logger)
    }

    vk.DestroyInstance(r.instance, nil)
}


_check_validation_layer_support :: proc() -> bool {
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

surface_create :: proc(r: ^Renderer_Impl, window: common.Window) -> (res: Result) {
    vk_res: vk.Result
    r.surface, vk_res = platform.create_vk_window_surface(r.instance, window)
    return check_result(vk_res)
}


surface_destroy :: proc(r: ^Renderer_Impl) {
    vk.DestroySurfaceKHR(r.instance, r.surface, nil)
}

// =========================================================================================


  /////////////////////
 // Physical Device //
/////////////////////

physical_device_select :: proc(r: ^Renderer_Impl) -> (res: Result) {
    phys_device_count: u32
    vk_res := vk.EnumeratePhysicalDevices(r.instance, &phys_device_count, nil)
    check_result(res) or_return

    phys_devices := make([]vk.PhysicalDevice, phys_device_count)
    defer delete(phys_devices)
    vk_res = vk.EnumeratePhysicalDevices(r.instance, &phys_device_count, raw_data(phys_devices))
    check_result(res) or_return


    for phys_device in phys_devices[:phys_device_count] {
        if _is_physical_device_suitable(r, phys_device) {
            r.physical_device = phys_device
            vk.GetPhysicalDeviceProperties(phys_device, &r.physical_device_properties)
            return .Ok
        }
    }

    log.error("No suitable physical devices")
    return .Device_Not_Supported
}

Queue_Family_Query :: struct {
    has_compute  : bool,
    has_graphics : bool,
    has_transfer : bool,
                 
    compute      : u32,
    graphics     : u32,
    transfer     : u32,
}


_is_physical_device_suitable :: proc(r: ^Renderer_Impl, phys_device: vk.PhysicalDevice) -> (ok: bool) {
    props: vk.PhysicalDeviceProperties
    feats: vk.PhysicalDeviceFeatures
    vk.GetPhysicalDeviceProperties(phys_device, &props)
    vk.GetPhysicalDeviceFeatures(phys_device, &feats)

    families := _find_queue_families(phys_device)
    families_adequate := _is_family_complete(&families)

    swap_details := _query_swapchain_support(phys_device, r.surface)
    defer _delete_swapchain_support(&swap_details)
    swap_adequate := len(swap_details.formats) > 0 && len(swap_details.present_modes) > 0

    suitable := _check_device_extension_support(phys_device, DEVICE_EXTS) &&
                families_adequate &&
                swap_adequate &&
                props.apiVersion >= API_VERSION

    when !config.RENDERER_HEADLESS {
        suitable &= (props.deviceType == .DISCRETE_GPU)
    }

    return suitable
}


_check_device_extension_support :: proc(phys_device: vk.PhysicalDevice, required_exts: []cstring) -> bool {
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

_find_queue_families :: proc(phys_device: vk.PhysicalDevice) -> Queue_Family_Query {
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

        if _is_family_complete(&families) {
            break
        }
    }

    return families
}


_is_family_complete :: proc(families: ^Queue_Family_Query) -> bool {
    is_complete :=  families.has_compute && 
                    families.has_transfer

    when !config.RENDERER_HEADLESS {
        is_complete &= families.has_graphics
    }

    return is_complete
}



// =========================================================================================


  ////////////
 // Device //
////////////

device_create :: proc(r: ^Renderer_Impl, desc: ^common.Engine_Description) -> (res: Result) {
    family_query := _find_queue_families(r.physical_device)

    r.queues = Queues {
        compute_family  = family_query.compute,
        graphics_family = family_query.graphics,
        transfer_family = family_query.transfer,
    }

    unique_family_idx_and_queue_counts:= make(map[u32]u32)
    defer delete(unique_family_idx_and_queue_counts)

    unique_family_idx_and_queue_counts[r.queues.compute_family]  += 1
    unique_family_idx_and_queue_counts[r.queues.transfer_family] += 1

    if !desc.renderer_description.headless {
        unique_family_idx_and_queue_counts[r.queues.graphics_family] += 1
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
    sync_features_2     := SYNC_FEATURES_2
    device_exts         := DEVICE_EXTS
    validation_layers   := VALIDATION_LAYERS

    device_create_info := vk.DeviceCreateInfo {
        sType                   = .DEVICE_CREATE_INFO,
        pNext                   = &sync_features_2,
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

    vk_res := vk.CreateDevice(r.physical_device, &device_create_info, nil, &r.device)
    check_result(vk_res) or_return

    unique_family_idx_and_queue_counts[r.queues.transfer_family] -= 1
    queue_idx := unique_family_idx_and_queue_counts[r.queues.transfer_family]
    vk.GetDeviceQueue(r.device, r.queues.transfer_family, queue_idx, &r.queues.transfer)
    
    unique_family_idx_and_queue_counts[r.queues.compute_family] -= 1
    queue_idx = unique_family_idx_and_queue_counts[r.queues.compute_family]
    vk.GetDeviceQueue(r.device, r.queues.compute_family, queue_idx, &r.queues.compute)
   
    if !desc.renderer_description.headless {
        unique_family_idx_and_queue_counts[r.queues.graphics_family] -= 1
        queue_idx = unique_family_idx_and_queue_counts[r.queues.graphics_family]
        vk.GetDeviceQueue(r.device, r.queues.graphics_family, queue_idx, &r.queues.graphics)
    }

    res = .Ok
    return 
}


device_destroy :: proc(r: ^Renderer_Impl) {
    vk.DestroyDevice(r.device, nil)
}

// =========================================================================================


  ///////////////////
 // Command Pools //
///////////////////

// Each frame in flight needs its own command pool
command_structures_create :: proc(r: ^Renderer_Impl) -> (res: Result) {
    create_info_compute := vk.CommandPoolCreateInfo {
        sType            = .COMMAND_POOL_CREATE_INFO,
        flags            = {.RESET_COMMAND_BUFFER},
        queueFamilyIndex = r.queues.compute_family,
    }

    create_info_graphics := vk.CommandPoolCreateInfo {
        sType            = .COMMAND_POOL_CREATE_INFO,
        flags            = {.RESET_COMMAND_BUFFER},
        queueFamilyIndex = r.queues.graphics_family,
    }
    
    create_info_transfer := vk.CommandPoolCreateInfo {
        sType            = .COMMAND_POOL_CREATE_INFO,
        flags            = {.RESET_COMMAND_BUFFER},
        queueFamilyIndex = r.queues.transfer_family,
    }
    
    alloc_info := vk.CommandBufferAllocateInfo {
        sType              = .COMMAND_BUFFER_ALLOCATE_INFO,
        commandBufferCount = 1,
        level              = .PRIMARY,
    }
    

    vk_res: vk.Result
    for &frame in r.frames {
        vk_res = vk.CreateCommandPool(r.device, &create_info_compute, nil, &frame.command_pools.compute)
        check_result(vk_res) or_return
        vk_res = vk.CreateCommandPool(r.device, &create_info_graphics, nil, &frame.command_pools.graphics)
        check_result(vk_res) or_return
        vk_res = vk.CreateCommandPool(r.device, &create_info_transfer, nil, &frame.command_pools.transfer)
        check_result(vk_res) or_return

        alloc_info.commandPool = frame.command_pools.compute
        vk_res = vk.AllocateCommandBuffers(r.device, &alloc_info, &frame.command_buffers.compute)
        check_result(vk_res) or_return
        
        alloc_info.commandPool = frame.command_pools.graphics
        vk_res = vk.AllocateCommandBuffers(r.device, &alloc_info, &frame.command_buffers.graphics)
        check_result(vk_res) or_return

        alloc_info.commandPool = frame.command_pools.transfer
        vk_res = vk.AllocateCommandBuffers(r.device, &alloc_info, &frame.command_buffers.transfer)
        check_result(vk_res) or_return
    }

    return .Ok
}


command_structures_destroy :: proc(r: ^Renderer_Impl) {
    for &frame in r.frames {
        vk.DestroyCommandPool(r.device, frame.command_pools.compute, nil)
        vk.DestroyCommandPool(r.device, frame.command_pools.graphics, nil)
        vk.DestroyCommandPool(r.device, frame.command_pools.transfer, nil)
    }
}


sync_structures_create :: proc(r: ^Renderer_Impl) -> (res: Result) {
    vk_res: vk.Result
    
    fence_create_info := vk.FenceCreateInfo {
        sType = .FENCE_CREATE_INFO,
        flags = {.SIGNALED},
    }

    sem_create_info := vk.SemaphoreCreateInfo {
        sType = .SEMAPHORE_CREATE_INFO,
        flags = {},
    }

    for &frame in r.frames {
        vk_res = vk.CreateFence(r.device, &fence_create_info, nil, &frame.fence_render)
        check_result(vk_res) or_return
        
        vk_res = vk.CreateSemaphore(r.device, &sem_create_info, nil, &frame.sem_render)
        check_result(vk_res) or_return
        vk_res = vk.CreateSemaphore(r.device, &sem_create_info, nil, &frame.sem_swapchain)
        check_result(vk_res) or_return
    }

    return .Ok
}


sync_structures_destroy :: proc(r: ^Renderer_Impl) {
    for &frame in r.frames {
        vk.DestroyFence(r.device, frame.fence_render, nil)
        vk.DestroySemaphore(r.device, frame.sem_render, nil)
        vk.DestroySemaphore(r.device, frame.sem_swapchain, nil)
    }
}


device_wait_idle :: proc(r: ^Renderer_Impl) {
    vk.DeviceWaitIdle(r.device)
}


current_frame :: proc(r: ^Renderer_Impl) -> (frame_data: ^Frame_Data) {
    return &r.frames[r.frame_idx]
}
