//+build windows, linux, darwin
//+private
package callisto_graphics

import "core:log"
import "core:strings"
import "core:math"
import "core:os"
import "core:mem"
import vk "vendor:vulkan"
import "../config"
// when config.BUILD_TARGET == .Desktop do import "vendor:glfw" // vk loader provided by glfw, might be worth moving vk loading to window init?
import "vendor:glfw"
import "../window"

validation_layers := [?]cstring{"VK_LAYER_KHRONOS_validation"}
required_instance_extensions: [dynamic]cstring = {/*vk.KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME*/}
required_device_extensions: [dynamic]cstring = {vk.KHR_SWAPCHAIN_EXTENSION_NAME}
dynamic_states: [dynamic]vk.DynamicState = {.VIEWPORT, .SCISSOR}

_get_global_proc_address :: proc(p: rawptr, name: cstring) {
    when config.BUILD_TARGET == .Desktop {
        (^rawptr)(p)^ = glfw.GetInstanceProcAddress(nil, name)
    }
}

_create_instance :: proc(instance: ^vk.Instance) -> (ok: bool) {
    res: vk.Result
    when config.BUILD_TARGET == .Desktop {
        // Add extensions required by glfw
        vk.load_proc_addresses_custom(_get_global_proc_address)

        window_exts := window.get_required_vk_extensions()
        append(&required_instance_extensions, ..window_exts)
    }
    when config.DEBUG_LOG_ENABLED {
        append(&required_instance_extensions, vk.EXT_DEBUG_UTILS_EXTENSION_NAME)
    }

    app_info := vk.ApplicationInfo {
        sType              = vk.StructureType.APPLICATION_INFO,
        pApplicationName   = cstring(config.APP_NAME),
        applicationVersion = vk.MAKE_VERSION(config.APP_VERSION[0], config.APP_VERSION[1], config.APP_VERSION[2]),
        pEngineName        = "Callisto",
        engineVersion      = vk.MAKE_VERSION(config.ENGINE_VERSION[0], config.ENGINE_VERSION[1], config.ENGINE_VERSION[2]),
        apiVersion         = vk.MAKE_VERSION(1, 1, 0),
    }

    instance_info := vk.InstanceCreateInfo {
        sType = vk.StructureType.INSTANCE_CREATE_INFO,
        pApplicationInfo = &app_info,
        flags = {/*.ENUMERATE_PORTABILITY_KHR*/},
        enabledExtensionCount = u32(len(required_instance_extensions)),
        ppEnabledExtensionNames = raw_data(required_instance_extensions),
    }

    when config.DEBUG_LOG_ENABLED {
        _init_logger()
        if _check_validation_layer_support(validation_layers[:]) == false {
            log.fatal("Requested Vulkan validation layer not available")
            return false
        }

        // debug_create_info := vk_impl.debug_messenger_create_info() 
        // instance_info.pNext = &debug_create_info
        instance_info.enabledLayerCount = len(validation_layers)
        instance_info.ppEnabledLayerNames = &validation_layers[0]
    }

    // Vulkan instance
    res = vk.CreateInstance(&instance_info, nil, instance); if res != .SUCCESS {
        log.fatal("Failed to create Vulkan instance:", res, required_instance_extensions)
        return false
    }
    defer if !ok do vk.DestroyInstance(instance^, nil)

    // Instance has been created, other procs are now available
    vk.load_proc_addresses_instance(instance^)

    return true
}

_create_debug_messenger :: proc(messenger: ^vk.DebugUtilsMessengerEXT) -> (ok: bool) {
    state := bound_state

    when config.DEBUG_LOG_ENABLED {
        // create debug messenger
        debug_create_info := _debug_messenger_create_info()
        res := vk.CreateDebugUtilsMessengerEXT(state.instance, &debug_create_info, nil, messenger); if res != .SUCCESS {
            log.fatal("Error creating debug messenger:", res)
            return false
        }
        defer if !ok do vk.DestroyDebugUtilsMessengerEXT(state.instance, messenger^, nil)
    }
    return true
}

_check_validation_layer_support :: proc(requested_layers: []cstring) -> bool {
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

_create_surface :: proc(surface: ^vk.SurfaceKHR) -> (ok: bool) {
    state := bound_state
    when config.BUILD_TARGET == .Desktop {
        res := glfw.CreateWindowSurface(state.instance, glfw.WindowHandle(window.handle), nil, surface); if res != .SUCCESS {
            log.fatal("Failed to create window surface:", res)
            return false
        }
        ok = true
        return
    }

    log.fatal("Platform not supported:", config.BUILD_TARGET)
    return false
}

_select_physical_device :: proc(physical_device: ^vk.PhysicalDevice) -> (ok: bool) {
    state := bound_state
    // TODO: Also allow user to specify desired GPU in graphics settings
    device_count: u32
    vk.EnumeratePhysicalDevices(state.instance, &device_count, nil)
    devices := make([]vk.PhysicalDevice, device_count)
    defer delete(devices)
    vk.EnumeratePhysicalDevices(state.instance, &device_count, raw_data(devices))

    highest_device: vk.PhysicalDevice = {}
    highest_score := -1
    for device in devices[:device_count] {
        score := _rank_physical_device(device, state.surface)
        if score > highest_score {
            highest_score = score
            highest_device = device
        }
    }

    if highest_score < 0 {
        log.fatal("No suitable physical devices available")
        return false
    }

    physical_device^ = highest_device
    return true
}

_rank_physical_device :: proc(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR) -> (score: int) {
    props: vk.PhysicalDeviceProperties
    features: vk.PhysicalDeviceFeatures
    vk.GetPhysicalDeviceProperties(physical_device, &props)
    vk.GetPhysicalDeviceFeatures(physical_device, &features)

    defer when config.DEBUG_LOG_ENABLED {
        log.info(cstring(raw_data(props.deviceName[:])), "Score:", score)
    }

    if _is_physical_device_suitable(physical_device, surface) == false do return -1
    if features.geometryShader == false do return -1
    if props.deviceType == .DISCRETE_GPU do score += 1000
    score += int(props.limits.maxImageDimension2D)

    return
}

_is_physical_device_suitable :: proc(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR) -> bool {
    families := _find_queue_family_indices(physical_device, surface)
    features: vk.PhysicalDeviceFeatures
    vk.GetPhysicalDeviceFeatures(physical_device, &features)

    ok := _is_queue_families_complete(&families)
    ok &= _check_device_extension_support(physical_device)
    ok &= features.samplerAnisotropy == true
    return ok
}

_find_queue_family_indices :: proc(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR,) -> (indices: Queue_Family_Indices) {
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


        if _is_queue_families_complete(&indices) do break
    }

    return
}

_is_queue_families_complete :: proc(indices: ^Queue_Family_Indices) -> (is_complete: bool) {
    _ = indices.graphics.? or_return
    _ = indices.present.? or_return
    return true
}

_create_logical_device :: proc(logical_device: ^vk.Device, queue_family_indices: ^Queue_Family_Indices, queue_handles: ^Queue_Handles) -> (ok: bool) {
    state := bound_state
    queue_family_indices^ = _find_queue_family_indices(state.physical_device, state.surface)

    // Queue families may have the same index. Only create one queue in this case.
    unique_indices_set := make(map[u32]struct {})
    defer delete(unique_indices_set)
    queue_create_infos := make([dynamic]vk.DeviceQueueCreateInfo)
    defer delete(queue_create_infos)

    unique_indices_set[queue_family_indices.graphics.?] = {}
    unique_indices_set[queue_family_indices.present.?] = {}

    queue_priority: f32 = 1.0
    for index in unique_indices_set {
        append(&queue_create_infos, _default_queue_create_info(index, &queue_priority))
    }


    features := vk.PhysicalDeviceFeatures {
        samplerAnisotropy = true,
    }

    device_create_info := vk.DeviceCreateInfo {
        sType                   = .DEVICE_CREATE_INFO,
        queueCreateInfoCount    = u32(len(queue_create_infos)),
        pQueueCreateInfos       = raw_data(queue_create_infos),
        pEnabledFeatures        = &features,
        enabledExtensionCount   = u32(len(required_device_extensions)),
        ppEnabledExtensionNames = raw_data(required_device_extensions),
    }

    when config.DEBUG_LOG_ENABLED {
        device_create_info.enabledLayerCount = len(validation_layers)
        device_create_info.ppEnabledLayerNames = &validation_layers[0]
    }

    res := vk.CreateDevice(state.physical_device, &device_create_info, nil, logical_device); if res != .SUCCESS {
        log.fatal("Failed to create logical device:", res)
        return false
    }

    vk.GetDeviceQueue(logical_device^, queue_family_indices.graphics.?, 0, &queue_handles.graphics)
    vk.GetDeviceQueue(logical_device^, queue_family_indices.present.?, 0, &queue_handles.present)

    return true
}

_default_queue_create_info :: proc(queue_family_index: u32, priority: ^f32) -> (info: vk.DeviceQueueCreateInfo) {
    info.sType = .DEVICE_QUEUE_CREATE_INFO
    info.queueCount = 1
    info.queueFamilyIndex = queue_family_index
    info.pQueuePriorities = priority
    return
}

_check_device_extension_support :: proc(physical_device: vk.PhysicalDevice) -> (ok: bool) {
    extension_count: u32
    vk.EnumerateDeviceExtensionProperties(physical_device, nil, &extension_count, nil)
    extension_props := make([]vk.ExtensionProperties, extension_count)
    defer delete(extension_props)
    vk.EnumerateDeviceExtensionProperties(physical_device, nil, &extension_count, &extension_props[0])

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

_create_swapchain :: proc(swapchain: ^vk.SwapchainKHR, swapchain_details: ^Swapchain_Details) -> (ok: bool) {
    state := bound_state
    ok = _select_swapchain_details(swapchain_details); if !ok {
        log.fatal("Swapchain is not suitable")
        return false
    }

    image_count: u32 = swapchain_details.capabilities.minImageCount + 1

    if swapchain_details.capabilities.maxImageCount > 0 &&
       image_count > swapchain_details.capabilities.maxImageCount {
        image_count = swapchain_details.capabilities.maxImageCount
    }


    swapchain_create_info := vk.SwapchainCreateInfoKHR {
        sType = .SWAPCHAIN_CREATE_INFO_KHR,
        surface = state.surface,
        minImageCount = image_count,
        imageFormat = swapchain_details.format.format,
        imageColorSpace = swapchain_details.format.colorSpace,
        imageExtent = swapchain_details.extent,
        imageArrayLayers = 1, // Change if using stereo rendering
        imageUsage = {.COLOR_ATTACHMENT},
        preTransform = swapchain_details.capabilities.currentTransform,
        compositeAlpha = {.OPAQUE},
        presentMode = swapchain_details.present_mode,
        clipped = true,
    }

    indices := _find_queue_family_indices(state.physical_device, state.surface)
    indices_values := [?]u32{indices.graphics.?, indices.present.?}
    if indices.graphics.? == indices.present.? {
        swapchain_create_info.imageSharingMode = .EXCLUSIVE
        swapchain_create_info.queueFamilyIndexCount = 2
        swapchain_create_info.pQueueFamilyIndices = &indices_values[0]
    } else {
        swapchain_create_info.imageSharingMode = .CONCURRENT
    }

    res := vk.CreateSwapchainKHR(state.device, &swapchain_create_info, nil, swapchain); if res != .SUCCESS {
        log.fatal("Failed to create swapchain:", res)
        return false
    }

    return true
}

_select_swapchain_details :: proc(details: ^Swapchain_Details) -> (ok: bool) {
    state := bound_state
    vk.GetPhysicalDeviceSurfaceCapabilitiesKHR(state.physical_device, state.surface, &details.capabilities)

    format_count: u32
    vk.GetPhysicalDeviceSurfaceFormatsKHR(state.physical_device, state.surface, &format_count, nil)
    formats := make([]vk.SurfaceFormatKHR, format_count)
    defer delete(formats)

    vk.GetPhysicalDeviceSurfaceFormatsKHR(state.physical_device, state.surface, &format_count, raw_data(formats))

    present_mode_count: u32
    vk.GetPhysicalDeviceSurfacePresentModesKHR(state.physical_device, state.surface, &present_mode_count, nil)

    present_modes := make([]vk.PresentModeKHR, present_mode_count)
    defer delete(present_modes)
    vk.GetPhysicalDeviceSurfacePresentModesKHR(state.physical_device, state.surface, &present_mode_count, raw_data(present_modes))

    ok = len(formats) > 0 && len(present_modes) > 0

    details.format = _select_swapchain_format(formats[:])
    details.present_mode = _select_swapchain_present_mode(present_modes[:])
    details.extent = _select_swapchain_extent(&details.capabilities)

    return
}

_select_swapchain_format :: proc(available_formats: []vk.SurfaceFormatKHR) -> vk.SurfaceFormatKHR {
    for format in available_formats {
        if format.format == .B8G8R8A8_SRGB && format.colorSpace == .SRGB_NONLINEAR {
            return format
        }
    }
    return available_formats[0]
}

_select_swapchain_present_mode :: proc(available_present_modes: []vk.PresentModeKHR) -> vk.PresentModeKHR {
    for mode in available_present_modes {
        if mode == .MAILBOX {
            return mode
        }
    }
    return .FIFO
}

_select_swapchain_extent :: proc(surface_capabilities: ^vk.SurfaceCapabilitiesKHR) -> (extent: vk.Extent2D) {
    if surface_capabilities.currentExtent.width != max(u32) {
        return surface_capabilities.currentExtent
    }

    when config.BUILD_TARGET == .Desktop {
        s_width, s_height := glfw.GetFramebufferSize(glfw.WindowHandle(window.handle))
        width := u32(s_width)
        height := u32(s_height)
        extent.width = math.clamp(width, surface_capabilities.minImageExtent.width, surface_capabilities.maxImageExtent.width)
        extent.height = math.clamp(height, surface_capabilities.minImageExtent.height, surface_capabilities.maxImageExtent.height)
        return
    }

    log.error("Build target not supported")
    return surface_capabilities.currentExtent
}

_get_images :: proc(images: ^[dynamic]vk.Image) {
    state := bound_state
    image_count: u32
    vk.GetSwapchainImagesKHR(state.device, state.swapchain, &image_count, nil)
    resize(images, int(image_count))
    vk.GetSwapchainImagesKHR(state.device, state.swapchain, &image_count, raw_data(images^))
}

_create_image_views :: proc(image_views: ^[dynamic]vk.ImageView) -> (ok: bool) {
    // Create image view for every image we have acquired
    resize(image_views, len(bound_state.images))
    for image, i in bound_state.images {
        ok = _create_image_view(image, bound_state.swapchain_details.format.format, {.COLOR}, &image_views[i]); if !ok {
            for j in 0..<i {
                _destroy_image_view(image_views[j])
            }
            return false
        }
    }
    return true
}

_destroy_image_views :: proc(image_views: ^[dynamic]vk.ImageView) {
    state := bound_state
    for image_view in image_views {
        _destroy_image_view(image_view)
    }

    clear(image_views)
}

_create_render_pass :: proc(render_pass: ^vk.RenderPass) -> (ok: bool) {
    state := bound_state
    subpass_dependency := vk.SubpassDependency {
        srcSubpass = vk.SUBPASS_EXTERNAL,
        dstSubpass = 0,
        srcStageMask = {.COLOR_ATTACHMENT_OUTPUT, .EARLY_FRAGMENT_TESTS},
        srcAccessMask = {},
        dstStageMask = {.COLOR_ATTACHMENT_OUTPUT, .EARLY_FRAGMENT_TESTS},
        dstAccessMask = {.COLOR_ATTACHMENT_WRITE, .DEPTH_STENCIL_ATTACHMENT_WRITE},
    }

    color_attachment_desc := vk.AttachmentDescription {
        format = state.swapchain_details.format.format,
        samples = {._1},
        loadOp = .CLEAR,
        storeOp = .STORE,
        stencilLoadOp = .DONT_CARE,
        stencilStoreOp = .DONT_CARE,
        initialLayout = .UNDEFINED,
        finalLayout = .PRESENT_SRC_KHR,
    }

    color_attachment_ref := vk.AttachmentReference {
        attachment = 0,
        layout     = .COLOR_ATTACHMENT_OPTIMAL,
    }

    depth_attachment_desc := vk.AttachmentDescription {
        format          = _find_depth_format(),
        samples         = {._1},
        loadOp          = .CLEAR,
        storeOp         = .DONT_CARE,
        stencilLoadOp   = .DONT_CARE,
        stencilStoreOp  = .DONT_CARE,
        initialLayout   = .UNDEFINED,
        finalLayout     = .DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
    }

    depth_attachment_ref := vk.AttachmentReference {
        attachment = 1,
        layout = .DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
    }

    subpass_desc := vk.SubpassDescription {
        pipelineBindPoint       = .GRAPHICS,
        colorAttachmentCount    = 1,
        pColorAttachments       = &color_attachment_ref,
        pDepthStencilAttachment = &depth_attachment_ref,
    }

    attachments := []vk.AttachmentDescription {
        color_attachment_desc,
        depth_attachment_desc,
    }

    render_pass_create_info := vk.RenderPassCreateInfo {
        sType           = .RENDER_PASS_CREATE_INFO,
        attachmentCount = u32(len(attachments)),
        pAttachments    = raw_data(attachments),
        subpassCount    = 1,
        pSubpasses      = &subpass_desc,
        dependencyCount = 1,
        pDependencies   = &subpass_dependency,
    }

    res := vk.CreateRenderPass(state.device, &render_pass_create_info, nil, render_pass); if res != .SUCCESS {
        log.fatal("Failed to create render pass:", res)
        return false
    }
    
    return true
}


_create_framebuffers :: proc(framebuffers: ^[dynamic]vk.Framebuffer) -> (ok: bool) {
    resize(framebuffers, len(bound_state.image_views))

    for image_view, i in bound_state.image_views {
        attachments := []vk.ImageView {
            image_view,
            bound_state.depth_image_view,
        }

        framebuffer_create_info := vk.FramebufferCreateInfo {
            sType           = .FRAMEBUFFER_CREATE_INFO,
            renderPass      = bound_state.render_pass,
            attachmentCount = u32(len(attachments)),
            pAttachments    = raw_data(attachments),
            width           = bound_state.swapchain_details.extent.width,
            height          = bound_state.swapchain_details.extent.height,
            layers          = 1,
        }

        res := vk.CreateFramebuffer(bound_state.device, &framebuffer_create_info, nil, &framebuffers[i]); if res != .SUCCESS {
            log.fatal("Failed to create framebuffers:", res)
            for j in 0 ..< i {
                vk.DestroyFramebuffer(bound_state.device, framebuffers[j], nil)
            }
            return false
        }
    }
    return true
}

_destroy_framebuffers :: proc(framebuffer_array: ^[dynamic]vk.Framebuffer) {
    state := bound_state
    for framebuffer in framebuffer_array {
        vk.DestroyFramebuffer(state.device, framebuffer, nil)
    }

    resize(framebuffer_array, 0)
}

_create_command_pool :: proc(command_pool: ^vk.CommandPool) -> (ok: bool) {
    state := bound_state
    command_pool_create_info := vk.CommandPoolCreateInfo {
        sType = .COMMAND_POOL_CREATE_INFO,
        flags = {.RESET_COMMAND_BUFFER},
        queueFamilyIndex = state.queue_family_indices.graphics.?,
    }

    res := vk.CreateCommandPool(state.device, &command_pool_create_info, nil, command_pool); if res != .SUCCESS {
        log.fatal("Failed to create command pool:", res)
        return false
    }

    ok = true
    return
}

_create_command_buffers :: proc(count: int, command_buffers: ^[dynamic]vk.CommandBuffer) -> (ok: bool) {
    state := bound_state
    resize(command_buffers, count)
    command_buffer_allocate_info := vk.CommandBufferAllocateInfo {
        sType              = .COMMAND_BUFFER_ALLOCATE_INFO,
        commandPool        = state.command_pool,
        level              = .PRIMARY,
        commandBufferCount = u32(count),
    }

    res := vk.AllocateCommandBuffers(state.device, &command_buffer_allocate_info, raw_data(command_buffers^)); if res != .SUCCESS {
        log.fatal("Failed to allocate command buffer:", res)
        return false
    }

    return true
}

_begin_command_buffer :: proc() -> (ok: bool) {
    state := bound_state
    command_buffer := state.command_buffers[state.flight_frame]
    begin_info := vk.CommandBufferBeginInfo {
        sType = .COMMAND_BUFFER_BEGIN_INFO,
        flags = {},
    }

    res := vk.BeginCommandBuffer(command_buffer, &begin_info); if res != .SUCCESS {
        log.fatal("Failed to begin recording command buffer:", res)
        return false
    }
    return true
}

_end_command_buffer :: proc() -> (ok: bool) {
    state := bound_state
    command_buffer := state.command_buffers[state.flight_frame]
    res := vk.EndCommandBuffer(command_buffer); if res != .SUCCESS {
        log.fatal("Failed to end recording command buffer:", res)
        return false
    }
    return true
}

_begin_render_pass :: proc() {
    state := bound_state
    command_buffer := state.command_buffers[state.flight_frame]
    clear_values := []vk.ClearValue {
        {color = {float32 = {0, 0, 0, 1}}},
        {depthStencil = { depth = 1, stencil = 0}},
    }

    render_pass_begin_info := vk.RenderPassBeginInfo {
        sType = .RENDER_PASS_BEGIN_INFO,
        renderPass = state.render_pass,
        framebuffer = state.framebuffers[state.target_image_index],
        renderArea = {offset = {0, 0}, extent = state.swapchain_details.extent},
        clearValueCount = u32(len(clear_values)),
        pClearValues = raw_data(clear_values),
    }

    vk.CmdBeginRenderPass(command_buffer, &render_pass_begin_info, .INLINE) // Switch to SECONDARY_command_bufferS later
    
    viewport := vk.Viewport {
        x        = 0,
        y        = 0,
        width    = f32(state.swapchain_details.extent.width),
        height   = f32(state.swapchain_details.extent.height),
        minDepth = 0,
        maxDepth = 1,
    }

    vk.CmdSetViewport(command_buffer, 0, 1, &viewport)

    scissor := vk.Rect2D {
        offset = {0, 0},
        extent = state.swapchain_details.extent,
    }

    vk.CmdSetScissor(command_buffer, 0, 1, &scissor)
}

_end_render_pass :: proc() {
    state := bound_state
    command_buffer := state.command_buffers[state.flight_frame]
    vk.CmdEndRenderPass(command_buffer)
}

_bind_shader :: proc(pipeline: vk.Pipeline) {
    state := bound_state
    command_buffer := state.command_buffers[state.flight_frame]
    vk.CmdBindPipeline(command_buffer, .GRAPHICS, pipeline)
}

_draw :: proc(/* vertex_buffer: */) {
    state := bound_state
    command_buffer := state.command_buffers[state.flight_frame]
    vk.CmdDraw(command_buffer, 3, 1, 0, 0)
}

_create_semaphores :: proc(count: int, semaphores: ^[dynamic]vk.Semaphore) -> (ok: bool) {
    state := bound_state
    resize(semaphores, count)
    
    semaphore_create_info := vk.SemaphoreCreateInfo {
        sType = .SEMAPHORE_CREATE_INFO,
    }

    for i in 0..<count {
        res := vk.CreateSemaphore(state.device, &semaphore_create_info, nil, &semaphores[i]); if res != .SUCCESS {
            log.fatal("Failed to create sempahores:", res)
            for j in 0..<i {
                vk.DestroySemaphore(state.device, semaphores[j], nil)
            }
            return false
        }
    }
    
    return true
}

_create_fences :: proc(count: int, fences: ^[dynamic]vk.Fence) -> (ok: bool) {
    state := bound_state
    resize(fences, int(count))

    fence_create_info := vk.FenceCreateInfo {
        sType = .FENCE_CREATE_INFO,
        flags = {.SIGNALED},
    }

    for i in 0..<count {
        res := vk.CreateFence(state.device, &fence_create_info, nil, &fences[i]); if res != .SUCCESS {
            log.fatal("Failed to create fences:", res)
            for j in 0..<i {
                vk.DestroyFence(state.device, fences[j], nil)
            }
            return false
        }
    }
    ok = true
    return
}

_destroy_semaphores :: proc(semaphores: ^[dynamic]vk.Semaphore) {
    state := bound_state
    for semaphore in semaphores^ {
        vk.DestroySemaphore(state.device, semaphore, nil)
    }

    resize(semaphores, 0)
}

_destroy_fences :: proc(fences: ^[dynamic]vk.Fence) {
    state := bound_state
    for fence in fences^ {
        vk.DestroyFence(state.device, fence, nil)
    }

    resize(fences, 0)
}


_submit_command_buffer :: proc() -> (ok: bool) {
    state := bound_state
    // Replace with arrays if required
    image_available_semaphore := state.image_available_semaphores[state.flight_frame]
    render_finished_semaphore := state.render_finished_semaphores[state.flight_frame]
    command_buffer := state.command_buffers[state.flight_frame]
    in_flight_fence := state.in_flight_fences[state.flight_frame]

    stage_flags := [?]vk.PipelineStageFlags{{.COLOR_ATTACHMENT_OUTPUT}}

    submit_info := vk.SubmitInfo {
        sType                = .SUBMIT_INFO,
        waitSemaphoreCount   = 1,
        pWaitSemaphores      = &image_available_semaphore,
        pWaitDstStageMask    = &stage_flags[0],
        commandBufferCount   = 1,
        pCommandBuffers      = &command_buffer,
        signalSemaphoreCount = 1,
        pSignalSemaphores    = &render_finished_semaphore,
    }

    res := vk.QueueSubmit(state.queues.graphics, 1, &submit_info, in_flight_fence); if res != .SUCCESS {
        log.fatal("Failed to submit command buffer:", res)
        return false
    }


    return true
}

_present :: proc() -> (ok: bool) {
    state := bound_state
    render_finished_semaphore := state.render_finished_semaphores[state.flight_frame]
    present_info := vk.PresentInfoKHR {
        sType              = .PRESENT_INFO_KHR,
        waitSemaphoreCount = 1,
        pWaitSemaphores    = &render_finished_semaphore,
        swapchainCount     = 1,
        pSwapchains        = &state.swapchain,
        pImageIndices      = &state.target_image_index,
    }

    res := vk.QueuePresentKHR(state.queues.graphics, &present_info); if res != .SUCCESS {
        switch {
        case res == .ERROR_OUT_OF_DATE_KHR:
            fallthrough
        case res == .SUBOPTIMAL_KHR:
            ok = _recreate_swapchain(&state.swapchain, &state.swapchain_details, &state.image_views, &state.framebuffers); if !ok {
                log.fatal("Failed to recreate swapchain after attempted present:", res)
                return false
            }
        case:
            log.fatal("Failed to present:", res)
            return false
        }
    }

    return true
}

_recreate_swapchain :: proc(swapchain: ^vk.SwapchainKHR, swapchain_details: ^Swapchain_Details, image_views: ^[dynamic]vk.ImageView, framebuffers: ^[dynamic]vk.Framebuffer) -> (ok: bool) {
    vk.DeviceWaitIdle(bound_state.device)

    _destroy_depth_image(bound_state.depth_image, bound_state.depth_image_memory, bound_state.depth_image_view)
    _destroy_framebuffers(framebuffers)
    _destroy_image_views(image_views)
    vk.DestroySwapchainKHR(bound_state.device, swapchain^, nil)

    _create_swapchain(swapchain, swapchain_details) or_return
    defer if !ok do vk.DestroySwapchainKHR(bound_state.device, swapchain^, nil)
    _create_image_views(image_views) or_return
    defer if !ok do _destroy_image_views(image_views)
    _create_depth_image(&bound_state.depth_image, &bound_state.depth_image_memory, &bound_state.depth_image_view)
    _create_framebuffers(framebuffers) or_return
    defer if !ok do _destroy_framebuffers(framebuffers)

    ok = true
    return
}


_find_memory_type :: proc(type_filter: u32, properties: vk.MemoryPropertyFlags) -> u32 {
    state := bound_state
    mem_properties: vk.PhysicalDeviceMemoryProperties
    vk.GetPhysicalDeviceMemoryProperties(state.physical_device, &mem_properties)
    for i in 0..<mem_properties.memoryTypeCount {
        if (type_filter & (1 << i) != 0) && ((mem_properties.memoryTypes[i].propertyFlags & properties) == properties) {
            return i
        }
    }
    log.error("Failed to find suitable memory type")
    return 0
}


_create_depth_image :: proc(depth_image: ^vk.Image, depth_image_memory: ^vk.DeviceMemory, depth_image_view: ^vk.ImageView) -> (ok: bool) {
    depth_format := _find_depth_format()
    if depth_format == .UNDEFINED do return false

    extents := bound_state.swapchain_details.extent
    _create_vk_image(extents.width, extents.height, depth_format, .OPTIMAL, {.DEPTH_STENCIL_ATTACHMENT}, {.DEVICE_LOCAL}, depth_image, depth_image_memory) or_return
    defer if !ok do vk.FreeMemory(bound_state.device, depth_image_memory^, nil)
    defer if !ok do vk.DestroyImage(bound_state.device, depth_image^, nil)

    _create_image_view(depth_image^, depth_format, {.DEPTH}, depth_image_view) or_return
    
    _transition_vk_image_layout(depth_image^, depth_format, .UNDEFINED ,.DEPTH_STENCIL_ATTACHMENT_OPTIMAL)

    return true
}

_destroy_depth_image :: proc(depth_image: vk.Image, depth_image_memory: vk.DeviceMemory, depth_image_view: vk.ImageView) {
    vk.DestroyImageView(bound_state.device, depth_image_view, nil)
    vk.DestroyImage(bound_state.device, depth_image, nil)
    vk.FreeMemory(bound_state.device, depth_image_memory, nil)
}


_find_supported_format :: proc(candidates: []vk.Format, tiling: vk.ImageTiling, required_features: vk.FormatFeatureFlags) -> vk.Format {
    for format in candidates {
        props : vk.FormatProperties
        vk.GetPhysicalDeviceFormatProperties(bound_state.physical_device, format, &props)

        #partial switch tiling {
            case .LINEAR:
                if props.linearTilingFeatures >= required_features {
                    return format
                }
            case .OPTIMAL:
                if props.optimalTilingFeatures >= required_features {
                    return format
                }
        }
    }

    log.error("Failed to find supported format")
    return .UNDEFINED
}

_find_depth_format :: proc() -> vk.Format {
    return _find_supported_format(
        {.D32_SFLOAT_S8_UINT, .D24_UNORM_S8_UINT, .D32_SFLOAT}, 
        .OPTIMAL, 
        {.DEPTH_STENCIL_ATTACHMENT})
}