package callisto_graphics_vkb

import vk "vendor:vulkan"
import vma "vulkan-memory-allocator"
import cc "../../common"
import "core:strings"
import "core:slice"
import "core:log"
import "core:math"
import "core:runtime"
import "core:intrinsics"
import "../../config"
import "../../platform"

API_VERSION :: vk.API_VERSION_1_3

INSTANCE_EXTS :: []cstring {}

ENABLE_VALIDATION_LAYERS :: ODIN_DEBUG

VALIDATION_LAYERS :: []cstring {
    "VK_LAYER_KHRONOS_validation",
}

DEVICE_EXTS :: []cstring {
    vk.KHR_SWAPCHAIN_EXTENSION_NAME,
}

DEVICE_FEATURES :: vk.PhysicalDeviceFeatures {}

// GRAPHICS CONTEXT
// ////////////////
init_graphics_context :: proc(cg_ctx: ^Graphics_Context) {
    cg_ctx.frame_data = make([]Frame_Data, config.RENDERER_FRAMES_IN_FLIGHT)
}

destroy_graphics_context :: proc(cg_ctx: ^Graphics_Context) {
    delete(cg_ctx.frame_data)
}

// INSTANCE
// ////////

create_instance :: proc(cg_ctx: ^Graphics_Context) -> (ok: bool) {
    vk.load_proc_addresses(rawptr(platform.get_vk_proc_address))

    check_validation_layer_support() or_return

    application_info := vk.ApplicationInfo {
        sType               = .APPLICATION_INFO,
        pApplicationName    = strings.unsafe_string_to_cstring(config.APP_NAME),
        applicationVersion  = vk.MAKE_VERSION(config.APP_VERSION.x, config.APP_VERSION.y, config.APP_VERSION.z),
        pEngineName         = strings.unsafe_string_to_cstring(config.ENGINE_NAME),
        engineVersion       = vk.MAKE_VERSION(config.ENGINE_VERSION.x, config.ENGINE_VERSION.y, config.ENGINE_VERSION.z),
        apiVersion          = API_VERSION,
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

    validation_layers := VALIDATION_LAYERS
    
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
       
        when config.DEBUG_RENDERER_INIT {
            instance_create_info.pNext = &debug_create_info
        }
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


check_validation_layer_support :: proc() -> (ok: bool) {
    when ENABLE_VALIDATION_LAYERS {
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

        outer: for requested_layer in VALIDATION_LAYERS {
            for avail_layer in available_layer_names {
                if runtime.cstring_cmp(avail_layer, requested_layer) == 0 {
                    continue outer
                }
            }

            // requested validation layer not in available layers
            log.error("Missing Vulkan validation layer:", requested_layer, "\n  Available layers:", available_layer_names)
            return false
        }
    }

    return true
}


// SURFACE
// ///////

create_surface :: proc(cg_ctx: ^Graphics_Context, window_ctx: ^platform.Window_Context) -> (ok: bool) {
    // TODO(headless): noop if running headless
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
    families_adequate := is_family_complete(&families)

    swap_details := query_swapchain_support(phys_device, cg_ctx.surface)
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


find_queue_families :: proc(phys_device: vk.PhysicalDevice) -> Queue_Families {
    queue_family_count: u32
    vk.GetPhysicalDeviceQueueFamilyProperties(phys_device, &queue_family_count, nil)
    
    queue_family_props := make([]vk.QueueFamilyProperties, queue_family_count)
    defer delete(queue_family_props)
    vk.GetPhysicalDeviceQueueFamilyProperties(phys_device, &queue_family_count, raw_data(queue_family_props))

    families: Queue_Families

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

is_family_complete :: proc(families: ^Queue_Families) -> bool {
    is_complete :=  families.has_compute && 
                    families.has_transfer

    when !config.RENDERER_HEADLESS {
        is_complete &= families.has_graphics
    }

    return is_complete
}


create_device :: proc(cg_ctx: ^Graphics_Context) -> (ok: bool) {
    families := find_queue_families(cg_ctx.physical_device)

    unique_family_idx_and_queue_counts:= make(map[u32]u32)
    defer delete(unique_family_idx_and_queue_counts)

    unique_family_idx_and_queue_counts[families.compute]  += 1
    unique_family_idx_and_queue_counts[families.transfer] += 1

    cg_ctx.compute_queue_family_idx  = families.compute
    cg_ctx.transfer_queue_family_idx = families.transfer
    
    when !config.RENDERER_HEADLESS {
        unique_family_idx_and_queue_counts[families.graphics] += 1
        cg_ctx.graphics_queue_family_idx = families.graphics
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
        enabledLayerCount       = ENABLE_VALIDATION_LAYERS ? u32(len(validation_layers)) : 0,
        ppEnabledLayerNames     = raw_data(validation_layers),
        enabledExtensionCount   = u32(len(device_exts)),
        ppEnabledExtensionNames = raw_data(device_exts),
    }

    res := vk.CreateDevice(cg_ctx.physical_device, &device_create_info, nil, &cg_ctx.device)
    check_result(res) or_return

    unique_family_idx_and_queue_counts[families.transfer] -= 1
    queue_idx := unique_family_idx_and_queue_counts[families.transfer]
    vk.GetDeviceQueue(cg_ctx.device, cg_ctx.transfer_queue_family_idx, queue_idx, &cg_ctx.transfer_queue)
    
    unique_family_idx_and_queue_counts[families.compute] -= 1
    queue_idx = unique_family_idx_and_queue_counts[families.compute]
    vk.GetDeviceQueue(cg_ctx.device, cg_ctx.compute_queue_family_idx, queue_idx, &cg_ctx.compute_queue)
   
    when !config.RENDERER_HEADLESS {
        unique_family_idx_and_queue_counts[families.graphics] -= 1
        queue_idx = unique_family_idx_and_queue_counts[families.graphics]
        vk.GetDeviceQueue(cg_ctx.device, cg_ctx.graphics_queue_family_idx, queue_idx, &cg_ctx.graphics_queue)
    }

    return true
}

destroy_device :: proc(cg_ctx: ^Graphics_Context) {
    vk.DestroyDevice(cg_ctx.device, nil)
}


// SWAPCHA
// /////////
Swapchain_Support_Details :: struct {
    capabilities:   vk.SurfaceCapabilitiesKHR,
    formats:        []vk.SurfaceFormatKHR,
    present_modes:  []vk.PresentModeKHR,
}

create_swapchain :: proc(cg_ctx: ^Graphics_Context, window_ctx: ^platform.Window_Context, old_swapchain: vk.SwapchainKHR = {}) -> (ok: bool) {
    if old_swapchain != {} {
        delete(cg_ctx.swapchain_images)
        delete(cg_ctx.swapchain_views)
    }

    swapchain_support := query_swapchain_support(cg_ctx.physical_device, cg_ctx.surface)
    defer delete_swapchain_support(&swapchain_support)

    // select image format
    swap_surface_fmt := swapchain_support.formats[0]
    for available_fmt in swapchain_support.formats {
        if available_fmt.format == .B8G8R8A8_SRGB && available_fmt.colorSpace == .SRGB_NONLINEAR {
            swap_surface_fmt = available_fmt
            cg_ctx.swapchain_format = available_fmt.format
            break
        }
    }

    // use requested present mode if availabe, otherwise FIFO as it's the only one guaranteed to be implemented
    swap_present_mode := vk.PresentModeKHR.FIFO
    wish_present_mode: vk.PresentModeKHR

    switch config.WINDOW_VSYNC {
    case .Triple_Buffer:
        wish_present_mode = .MAILBOX
    case .Vsync:
        wish_present_mode = .FIFO
    case .Off:
        wish_present_mode = .IMMEDIATE
    }

    for available_present_mode in swapchain_support.present_modes {
        if available_present_mode == wish_present_mode {
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

    cg_ctx.swapchain_extents = swap_extent

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
        compositeAlpha      = {.OPAQUE},
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

    actual_image_count: u32
    res = vk.GetSwapchainImagesKHR(cg_ctx.device, cg_ctx.swapchain, &actual_image_count, nil)
    check_result(res) or_return

    cg_ctx.swapchain_images = make([]vk.Image, actual_image_count)
    cg_ctx.swapchain_views  = make([]vk.ImageView, actual_image_count)
    res = vk.GetSwapchainImagesKHR(cg_ctx.device, cg_ctx.swapchain, &actual_image_count, raw_data(cg_ctx.swapchain_images))
    check_result(res) or_return

    for swap_img, i in cg_ctx.swapchain_images {
        view_create_info := vk.ImageViewCreateInfo {
            sType               = .IMAGE_VIEW_CREATE_INFO,
            image               = swap_img,
            viewType            = .D2,
            format              = cg_ctx.swapchain_format,
            components          = {}, // RGBA Identity by default
            subresourceRange    = {
                aspectMask      = {.COLOR},
                baseMipLevel    = 0,
                levelCount      = 1,
                baseArrayLayer  = 0,
                layerCount      = 1,
            }
        }

        res = vk.CreateImageView(cg_ctx.device, &view_create_info, nil, &(cg_ctx.swapchain_views[i]))
        check_result(res) or_return
    }
    
    return true
}


destroy_swapchain :: proc(cg_ctx: ^Graphics_Context) {
    for img_view in cg_ctx.swapchain_views {
        vk.DestroyImageView(cg_ctx.device, img_view, nil)
    }

    delete(cg_ctx.swapchain_images)
    delete(cg_ctx.swapchain_views)
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


// COMMAND RESOURCES
// /////////////////

create_command_pools :: proc(cg_ctx: ^Graphics_Context) -> (ok: bool) {
    pool_create_info := vk.CommandPoolCreateInfo {
        sType               = .COMMAND_POOL_CREATE_INFO,
        flags               = {.RESET_COMMAND_BUFFER},
    }
    
    // Transfer
    pool_create_info.queueFamilyIndex = cg_ctx.transfer_queue_family_idx
    res := vk.CreateCommandPool(cg_ctx.device, &pool_create_info, nil, &cg_ctx.transfer_pool)
    check_result(res) or_return

    // Compute
    pool_create_info.queueFamilyIndex = cg_ctx.compute_queue_family_idx
    res = vk.CreateCommandPool(cg_ctx.device, &pool_create_info, nil, &cg_ctx.compute_pool)
    check_result(res) or_return

    // Graphics
    when !config.RENDERER_HEADLESS {
        pool_create_info.queueFamilyIndex = cg_ctx.graphics_queue_family_idx
        
        for &frame in cg_ctx.frame_data {
            res = vk.CreateCommandPool(cg_ctx.device, &pool_create_info, nil, &frame.graphics_pool)
            check_result(res) or_return
        }
    }

    return true
}


destroy_command_pools :: proc(cg_ctx: ^Graphics_Context) {
    vk.DestroyCommandPool(cg_ctx.device, cg_ctx.transfer_pool, nil)
    vk.DestroyCommandPool(cg_ctx.device, cg_ctx.compute_pool, nil)
    when !config.RENDERER_HEADLESS {
        for &frame in cg_ctx.frame_data {
            vk.DestroyCommandPool(cg_ctx.device, frame.graphics_pool, nil)
        }
    }
}


create_builtin_command_buffers :: proc(cg_ctx: ^Graphics_Context) -> (ok: bool) {
    // Transfer
    cb_transfer_allocate_info := vk.CommandBufferAllocateInfo {
        sType               = .COMMAND_BUFFER_ALLOCATE_INFO,
        commandPool         = cg_ctx.transfer_pool,
        level               = .PRIMARY,
        commandBufferCount  = 1,
    }

    res := vk.AllocateCommandBuffers(cg_ctx.device, &cb_transfer_allocate_info, &cg_ctx.transfer_command_buffer)
    check_result(res) or_return
        
    // Graphics
    when !config.RENDERER_HEADLESS {
        for &frame in cg_ctx.frame_data {
            cb_graphics_allocate_info := vk.CommandBufferAllocateInfo {
                sType               = .COMMAND_BUFFER_ALLOCATE_INFO,
                commandPool         = frame.graphics_pool,
                level               = .PRIMARY,
                commandBufferCount  = 1,
            }

            res = vk.AllocateCommandBuffers(cg_ctx.device, &cb_graphics_allocate_info, &frame.graphics_command_buffer)
            check_result(res) or_return
        }
    }

    return true
}

destroy_builtin_command_buffers :: proc(cg_ctx: ^Graphics_Context) {
    // Transfer
    vk.FreeCommandBuffers(cg_ctx.device, cg_ctx.transfer_pool, 1, &cg_ctx.transfer_command_buffer)

    // Graphics
    when !config.RENDERER_HEADLESS {
        for &frame in cg_ctx.frame_data {
            vk.FreeCommandBuffers(cg_ctx.device, frame.graphics_pool, 1, &frame.graphics_command_buffer)
        }
    }
}


// RENDER PASS
// ///////////

create_builtin_render_pass :: proc(cg_ctx: ^Graphics_Context) -> (ok: bool) {
    // TODO(headless): noop if running in headless

    // All attachments used in the entire render pass
    attachment_descs := []vk.AttachmentDescription {
        {
            format          = cg_ctx.swapchain_format,
            samples         = {._1}, // TODO: Antialiasing
            loadOp          = .CLEAR,
            storeOp         = .STORE,
            stencilLoadOp   = .DONT_CARE,
            stencilStoreOp  = .DONT_CARE,
            initialLayout   = .UNDEFINED,
            finalLayout     = .PRESENT_SRC_KHR,
        },
    }

    // References attachments to be used in a subpass and describes how they're used
    // One of these slices may be made per subpass
    color_refs := []vk.AttachmentReference {
        {
            attachment  = 0,
            layout      = .COLOR_ATTACHMENT_OPTIMAL,
        },
    }


    // Describes all subpasses used in the render pass
    subpass_descs := []vk.SubpassDescription {
        {
            pipelineBindPoint       = .GRAPHICS,
            colorAttachmentCount    = u32(len(color_refs)),
            pColorAttachments       = raw_data(color_refs),
        },
    }
    
    // Describes the flow of subpasses
    subpass_depends := []vk.SubpassDependency {
        {
            srcSubpass      = vk.SUBPASS_EXTERNAL,          // Subpass entry point
            dstSubpass      = 0,                            // Subpass index 0
            srcStageMask    = {.COLOR_ATTACHMENT_OUTPUT},
            srcAccessMask   = {},
            dstStageMask    = {.COLOR_ATTACHMENT_OUTPUT},
            dstAccessMask   = {.COLOR_ATTACHMENT_WRITE},
        },
    }

    render_pass_create_info := vk.RenderPassCreateInfo {
        sType           = .RENDER_PASS_CREATE_INFO,
        attachmentCount = u32(len(attachment_descs)),
        pAttachments    = raw_data(attachment_descs),
        subpassCount    = u32(len(subpass_descs)),
        pSubpasses      = raw_data(subpass_descs),
        dependencyCount = u32(len(subpass_depends)),
        pDependencies   = raw_data(subpass_depends),
    }

    res := vk.CreateRenderPass(cg_ctx.device, &render_pass_create_info, nil, &cg_ctx.render_pass)
    check_result(res) or_return

    return true
}


destroy_builtin_render_pass :: proc(cg_ctx: ^Graphics_Context) {
    vk.DestroyRenderPass(cg_ctx.device, cg_ctx.render_pass, nil)
}


create_framebuffers :: proc(cg_ctx: ^Graphics_Context, render_pass: vk.RenderPass) -> (framebuffers: []vk.Framebuffer, ok: bool) {
    framebuffers = make([]vk.Framebuffer, len(cg_ctx.swapchain_images))

    fb_create_info := vk.FramebufferCreateInfo {
        sType           = .FRAMEBUFFER_CREATE_INFO,
        renderPass      = render_pass,
        attachmentCount = 1,
        width           = cg_ctx.swapchain_extents.width,
        height          = cg_ctx.swapchain_extents.height,
        layers          = 1,
    }

    for _, i in framebuffers {
        fb_create_info.pAttachments = &cg_ctx.swapchain_views[i]
        res := vk.CreateFramebuffer(cg_ctx.device, &fb_create_info, nil, &framebuffers[i])
        check_result(res) or_return
    } 

    return framebuffers, true
}


destroy_framebuffers :: proc(cg_ctx: ^Graphics_Context, framebuffers: []vk.Framebuffer) {
    for framebuffer in framebuffers {
        vk.DestroyFramebuffer(cg_ctx.device, framebuffer, nil)
    }

    delete(framebuffers)
}


// SYNC STRUCTURES
// ///////////////

create_sync_structures :: proc(cg_ctx: ^Graphics_Context) -> (ok: bool) {
    sem_info := vk.SemaphoreCreateInfo {
        sType = .SEMAPHORE_CREATE_INFO,
    }

    fence_info := vk.FenceCreateInfo {
        sType = .FENCE_CREATE_INFO,
        flags = {.SIGNALED},
    }

    for &frame in cg_ctx.frame_data {
        res := vk.CreateSemaphore(cg_ctx.device, &sem_info, nil, &frame.image_available_sem)
        check_result(res) or_return
        res  = vk.CreateSemaphore(cg_ctx.device, &sem_info, nil, &frame.present_ready_sem)
        check_result(res) or_return
        res  = vk.CreateFence(cg_ctx.device, &fence_info, nil, &frame.in_flight_fence)
        check_result(res) or_return
    }

    return true
}

destroy_sync_structures :: proc(cg_ctx: ^Graphics_Context) {
    for &frame in cg_ctx.frame_data {
        vk.DestroySemaphore(cg_ctx.device, frame.image_available_sem, nil)
        vk.DestroySemaphore(cg_ctx.device, frame.present_ready_sem, nil)
        vk.DestroyFence(cg_ctx.device, frame.in_flight_fence, nil)
    }
}


// ALLOCATOR
// /////////

create_allocator :: proc(cg_ctx: ^Graphics_Context) -> (ok: bool) {
    vk_funcs := vma.create_vulkan_functions()

    allocator_info := vma.AllocatorCreateInfo {
        physicalDevice = cg_ctx.physical_device,
        device = cg_ctx.device,
        instance = cg_ctx.instance,
        pVulkanFunctions = &vk_funcs,
        vulkanApiVersion = API_VERSION,
    }
    
    res := vma.CreateAllocator(&allocator_info, &cg_ctx.allocator)
    check_result(res) or_return

    return true
} 

destroy_allocator :: proc(cg_ctx: ^Graphics_Context) {
    vma.DestroyAllocator(cg_ctx.allocator)
} 


