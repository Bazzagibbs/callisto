package callisto_graphics_vulkan

import "core:log"
import "core:strings"
import "core:math"
import "core:os"
import "core:mem"
import vk "vendor:vulkan"
import "../../config"
when config.BUILD_TARGET == .Desktop do import "vendor:glfw" // vk loader provided by glfw, might be worth moving vk loading to window init?
import "../../window"

validation_layers := [?]cstring{"VK_LAYER_KHRONOS_validation"}
required_instance_extensions: [dynamic]cstring = {/*vk.KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME*/}
required_device_extensions: [dynamic]cstring = {vk.KHR_SWAPCHAIN_EXTENSION_NAME}
dynamic_states: [dynamic]vk.DynamicState = {.VIEWPORT, .SCISSOR}

get_global_proc_address :: proc(p: rawptr, name: cstring) {
    when config.BUILD_TARGET == .Desktop {
        (^rawptr)(p)^ = glfw.GetInstanceProcAddress(nil, name)
    }
}

create_instance :: proc(instance: ^vk.Instance) -> (ok: bool) {
    res: vk.Result
    when config.BUILD_TARGET == .Desktop {
        // Add extensions required by glfw
        vk.load_proc_addresses_custom(get_global_proc_address)

        window_exts := window.get_required_vk_extensions()
        append(&required_instance_extensions, ..window_exts)
    }
    when config.ENGINE_DEBUG {
        append(&required_instance_extensions, vk.EXT_DEBUG_UTILS_EXTENSION_NAME)
    }

    app_info: vk.ApplicationInfo = {
        sType              = vk.StructureType.APPLICATION_INFO,
        pApplicationName   = cstring(config.APP_NAME),
        applicationVersion = vk.MAKE_VERSION(config.APP_VERSION[0], config.APP_VERSION[1], config.APP_VERSION[2]),
        pEngineName        = "Callisto",
        engineVersion      = vk.MAKE_VERSION(config.ENGINE_VERSION[0], config.ENGINE_VERSION[1], config.ENGINE_VERSION[2]),
        apiVersion         = vk.MAKE_VERSION(1, 1, 0),
    }

    instance_info: vk.InstanceCreateInfo = {
        sType = vk.StructureType.INSTANCE_CREATE_INFO,
        pApplicationInfo = &app_info,
        flags = {/*.ENUMERATE_PORTABILITY_KHR*/},
        enabledExtensionCount = u32(len(required_instance_extensions)),
        ppEnabledExtensionNames = raw_data(required_instance_extensions),
    }

    when config.ENGINE_DEBUG {
        init_logger()
        if check_validation_layer_support(validation_layers[:]) == false {
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

create_debug_messenger :: proc(messenger: ^vk.DebugUtilsMessengerEXT) -> (ok: bool) {
    state := bound_state

    when config.ENGINE_DEBUG {
        // create debug messenger
        debug_create_info := debug_messenger_create_info()
        res := vk.CreateDebugUtilsMessengerEXT(state.instance, &debug_create_info, nil, messenger); if res != .SUCCESS {
            log.fatal("Error creating debug messenger:", res)
            return false
        }
        defer if !ok do vk.DestroyDebugUtilsMessengerEXT(state.instance, messenger^, nil)
    }
    return true
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

create_surface :: proc(surface: ^vk.SurfaceKHR) -> (ok: bool) {
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

select_physical_device :: proc(physical_device: ^vk.PhysicalDevice) -> (ok: bool) {
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
        score := rank_physical_device(device, state.surface)
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

rank_physical_device :: proc(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR) -> (score: int) {
    props: vk.PhysicalDeviceProperties
    features: vk.PhysicalDeviceFeatures
    vk.GetPhysicalDeviceProperties(physical_device, &props)
    vk.GetPhysicalDeviceFeatures(physical_device, &features)

    defer when config.ENGINE_DEBUG {
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

find_queue_family_indices :: proc(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR,) -> (indices: Queue_Family_Indices) {
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

create_logical_device :: proc(logical_device: ^vk.Device, queue_family_indices: ^Queue_Family_Indices, queue_handles: ^Queue_Handles) -> (ok: bool) {
    state := bound_state
    queue_family_indices^ = find_queue_family_indices(state.physical_device, state.surface)

    // Queue families may have the same index. Only create one queue in this case.
    unique_indices_set := make(map[u32]struct {})
    defer delete(unique_indices_set)
    queue_create_infos := make([dynamic]vk.DeviceQueueCreateInfo)
    defer delete(queue_create_infos)

    unique_indices_set[queue_family_indices.graphics.?] = {}
    unique_indices_set[queue_family_indices.present.?] = {}

    queue_priority: f32 = 1.0
    for index in unique_indices_set {
        append(&queue_create_infos, default_queue_create_info(index, &queue_priority))
    }


    features: vk.PhysicalDeviceFeatures = {}

    device_create_info: vk.DeviceCreateInfo = {
        sType                   = .DEVICE_CREATE_INFO,
        queueCreateInfoCount    = u32(len(queue_create_infos)),
        pQueueCreateInfos       = raw_data(queue_create_infos),
        pEnabledFeatures        = &features,
        enabledExtensionCount   = u32(len(required_device_extensions)),
        ppEnabledExtensionNames = raw_data(required_device_extensions),
    }

    when config.ENGINE_DEBUG {
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

create_swapchain :: proc(swapchain: ^vk.SwapchainKHR, swapchain_details: ^Swapchain_Details) -> (ok: bool) {
    state := bound_state
    ok = select_swapchain_details(swapchain_details); if !ok {
        log.fatal("Swapchain is not suitable")
        return false
    }

    image_count: u32 = swapchain_details.capabilities.minImageCount + 1

    if swapchain_details.capabilities.maxImageCount > 0 &&
       image_count > swapchain_details.capabilities.maxImageCount {
        image_count = swapchain_details.capabilities.maxImageCount
    }


    swapchain_create_info: vk.SwapchainCreateInfoKHR = {
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

    indices := find_queue_family_indices(state.physical_device, state.surface)
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

select_swapchain_details :: proc(details: ^Swapchain_Details) -> (ok: bool) {
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

    details.format = select_swapchain_format(formats[:])
    details.present_mode = select_swapchain_present_mode(present_modes[:])
    details.extent = select_swapchain_extent(&details.capabilities)

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

get_images :: proc(images: ^[dynamic]vk.Image) {
    state := bound_state
    image_count: u32
    vk.GetSwapchainImagesKHR(state.device, state.swapchain, &image_count, nil)
    resize(images, int(image_count))
    vk.GetSwapchainImagesKHR(state.device, state.swapchain, &image_count, raw_data(images^))
}

create_image_views :: proc(image_views: ^[dynamic]vk.ImageView) -> (ok: bool) {
    state := bound_state
    // Create image view for every image we have acquired
    resize(image_views, len(state.images))
    for image, i in state.images {
        image_view_create_info: vk.ImageViewCreateInfo = {
            sType = .IMAGE_VIEW_CREATE_INFO,
            image = image,
            viewType = .D2,
            format = state.swapchain_details.format.format,
            components = {.IDENTITY, .IDENTITY, .IDENTITY, .IDENTITY},
            subresourceRange = {
                aspectMask = {.COLOR},
                baseMipLevel = 0,
                levelCount = 1,
                baseArrayLayer = 0,
                layerCount = 1,
            },
        }

        res := vk.CreateImageView(state.device, &image_view_create_info, nil, &image_views[i]); if res != .SUCCESS {
            log.fatal("Failed to create image views:", res)
            // Destroy any successfully created image views
            for j in 0 ..< i {
                vk.DestroyImageView(state.device, image_views[j], nil)
            }
            return false
        }
    }
    return true
}

destroy_image_views :: proc(image_views: ^[dynamic]vk.ImageView) {
    state := bound_state
    for image_view in image_views {
        vk.DestroyImageView(state.device, image_view, nil)
    }

    resize(image_views, 0)
}

create_render_pass :: proc(render_pass: ^vk.RenderPass) -> (ok: bool) {
    state := bound_state
    subpass_dependency: vk.SubpassDependency = {
        srcSubpass = vk.SUBPASS_EXTERNAL,
        dstSubpass = 0,
        srcStageMask = {.COLOR_ATTACHMENT_OUTPUT},
        srcAccessMask = {},
        dstStageMask = {.COLOR_ATTACHMENT_OUTPUT},
        dstAccessMask = {.COLOR_ATTACHMENT_WRITE},
    }

    color_attachment_desc: vk.AttachmentDescription = {
        format = state.swapchain_details.format.format,
        samples = {._1},
        loadOp = .CLEAR,
        storeOp = .STORE,
        stencilLoadOp = .DONT_CARE,
        stencilStoreOp = .DONT_CARE,
        initialLayout = .UNDEFINED,
        finalLayout = .PRESENT_SRC_KHR,
    }

    color_attachment_ref: vk.AttachmentReference = {
        attachment = 0,
        layout     = .COLOR_ATTACHMENT_OPTIMAL,
    }

    subpass_desc: vk.SubpassDescription = {
        pipelineBindPoint    = .GRAPHICS,
        colorAttachmentCount = 1,
        pColorAttachments    = &color_attachment_ref,
    }

    render_pass_create_info: vk.RenderPassCreateInfo = {
        sType           = .RENDER_PASS_CREATE_INFO,
        attachmentCount = 1,
        pAttachments    = &color_attachment_desc,
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


create_framebuffers :: proc(framebuffers: ^[dynamic]vk.Framebuffer) -> (ok: bool) {
    state := bound_state
    resize(framebuffers, len(state.image_views))

    for i in 0 ..< len(state.image_views) {
        framebuffer_create_info: vk.FramebufferCreateInfo = {
            sType           = .FRAMEBUFFER_CREATE_INFO,
            renderPass      = state.render_pass,
            attachmentCount = 1,
            pAttachments    = &state.image_views[i],
            width           = state.swapchain_details.extent.width,
            height          = state.swapchain_details.extent.height,
            layers          = 1,
        }

        res := vk.CreateFramebuffer(state.device, &framebuffer_create_info, nil, &framebuffers[i]); if res != .SUCCESS {
            log.fatal("Failed to create framebuffers:", res)
            for j in 0 ..< i {
                vk.DestroyFramebuffer(state.device, framebuffers[j], nil)
            }
            return false
        }
    }
    return true
}

destroy_framebuffers :: proc(framebuffer_array: ^[dynamic]vk.Framebuffer) {
    state := bound_state
    for framebuffer in framebuffer_array {
        vk.DestroyFramebuffer(state.device, framebuffer, nil)
    }

    resize(framebuffer_array, 0)
}

create_command_pool :: proc(command_pool: ^vk.CommandPool) -> (ok: bool) {
    state := bound_state
    command_pool_create_info: vk.CommandPoolCreateInfo = {
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

create_command_buffers :: proc(count: int, command_buffers: ^[dynamic]vk.CommandBuffer) -> (ok: bool) {
    state := bound_state
    resize(command_buffers, count)
    command_buffer_allocate_info: vk.CommandBufferAllocateInfo = {
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

begin_command_buffer :: proc() -> (ok: bool) {
    state := bound_state
    command_buffer := state.command_buffers[state.flight_frame]
    begin_info: vk.CommandBufferBeginInfo = {
        sType = .COMMAND_BUFFER_BEGIN_INFO,
        flags = {},
    }

    res := vk.BeginCommandBuffer(command_buffer, &begin_info); if res != .SUCCESS {
        log.fatal("Failed to begin recording command buffer:", res)
        return false
    }
    return true
}

end_command_buffer :: proc() -> (ok: bool) {
    state := bound_state
    command_buffer := state.command_buffers[state.flight_frame]
    res := vk.EndCommandBuffer(command_buffer); if res != .SUCCESS {
        log.fatal("Failed to end recording command buffer:", res)
        return false
    }
    return true
}

begin_render_pass :: proc() {
    state := bound_state
    command_buffer := state.command_buffers[state.flight_frame]
    clear_color: vk.ClearValue = {
        color = {float32 = {0, 0, 0, 1}},
    }

    render_pass_begin_info: vk.RenderPassBeginInfo = {
        sType = .RENDER_PASS_BEGIN_INFO,
        renderPass = state.render_pass,
        framebuffer = state.framebuffers[state.target_image_index],
        renderArea = {offset = {0, 0}, extent = state.swapchain_details.extent},
        clearValueCount = 1,
        pClearValues = &clear_color,
    }

    vk.CmdBeginRenderPass(command_buffer, &render_pass_begin_info, .INLINE) // Switch to SECONDARY_command_bufferS later
    
    viewport: vk.Viewport = {
        x        = 0,
        y        = 0,
        width    = f32(state.swapchain_details.extent.width),
        height   = f32(state.swapchain_details.extent.height),
        minDepth = 0,
        maxDepth = 1,
    }

    vk.CmdSetViewport(command_buffer, 0, 1, &viewport)

    scissor: vk.Rect2D = {
        offset = {0, 0},
        extent = state.swapchain_details.extent,
    }

    vk.CmdSetScissor(command_buffer, 0, 1, &scissor)
}

end_render_pass :: proc() {
    state := bound_state
    command_buffer := state.command_buffers[state.flight_frame]
    vk.CmdEndRenderPass(command_buffer)
}

bind_shader :: proc(pipeline: vk.Pipeline) {
    state := bound_state
    command_buffer := state.command_buffers[state.flight_frame]
    vk.CmdBindPipeline(command_buffer, .GRAPHICS, pipeline)
}

draw :: proc(/* vertex_buffer: */) {
    state := bound_state
    command_buffer := state.command_buffers[state.flight_frame]
    vk.CmdDraw(command_buffer, 3, 1, 0, 0)
}

create_semaphores :: proc(count: int, semaphores: ^[dynamic]vk.Semaphore) -> (ok: bool) {
    state := bound_state
    resize(semaphores, count)
    
    semaphore_create_info: vk.SemaphoreCreateInfo = {
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

create_fences :: proc(count: int, fences: ^[dynamic]vk.Fence) -> (ok: bool) {
    state := bound_state
    resize(fences, int(count))

    fence_create_info: vk.FenceCreateInfo = {
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

destroy_semaphores :: proc(semaphores: ^[dynamic]vk.Semaphore) {
    state := bound_state
    for semaphore in semaphores^ {
        vk.DestroySemaphore(state.device, semaphore, nil)
    }

    resize(semaphores, 0)
}

destroy_fences :: proc(fences: ^[dynamic]vk.Fence) {
    state := bound_state
    for fence in fences^ {
        vk.DestroyFence(state.device, fence, nil)
    }

    resize(fences, 0)
}


submit_command_buffer :: proc() -> (ok: bool) {
    state := bound_state
    // Replace with arrays if required
    image_available_semaphore := state.image_available_semaphores[state.flight_frame]
    render_finished_semaphore := state.render_finished_semaphores[state.flight_frame]
    command_buffer := state.command_buffers[state.flight_frame]
    in_flight_fence := state.in_flight_fences[state.flight_frame]

    stage_flags := [?]vk.PipelineStageFlags{{.COLOR_ATTACHMENT_OUTPUT}}

    submit_info: vk.SubmitInfo = {
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

present :: proc() -> (ok: bool) {
    state := bound_state
    render_finished_semaphore := state.render_finished_semaphores[state.flight_frame]
    present_info: vk.PresentInfoKHR = {
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
            ok = recreate_swapchain(&state.swapchain, &state.swapchain_details, &state.image_views, &state.framebuffers); if !ok {
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

recreate_swapchain :: proc(swapchain: ^vk.SwapchainKHR, swapchain_details: ^Swapchain_Details, image_views: ^[dynamic]vk.ImageView, framebuffers: ^[dynamic]vk.Framebuffer) -> (ok: bool) {
    state := bound_state
    vk.DeviceWaitIdle(state.device)

    destroy_framebuffers(framebuffers)
    destroy_image_views(image_views)
    vk.DestroySwapchainKHR(state.device, swapchain^, nil)

    create_swapchain(swapchain, swapchain_details) or_return
    defer if !ok do vk.DestroySwapchainKHR(state.device, swapchain^, nil)
    create_image_views(image_views) or_return
    defer if !ok do destroy_image_views(image_views)
    create_framebuffers(framebuffers) or_return
    defer if !ok do destroy_framebuffers(framebuffers)

    ok = true
    return
}


find_memory_type :: proc(type_filter: u32, properties: vk.MemoryPropertyFlags) -> u32 {
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

create_descriptor_pool :: proc(descriptor_pool: ^vk.DescriptorPool) -> (ok: bool) {
    // using bound_state // shadows descriptor_pool parameter

    pool_size: vk.DescriptorPoolSize = {
        type = .UNIFORM_BUFFER,
        descriptorCount = u32(config.RENDERER_FRAMES_IN_FLIGHT),
    }

    descriptor_pool_create_info: vk.DescriptorPoolCreateInfo = {
        sType = .DESCRIPTOR_POOL_CREATE_INFO,
        poolSizeCount = 1,
        pPoolSizes = &pool_size,
        maxSets = u32(config.RENDERER_FRAMES_IN_FLIGHT),
    }

    res := vk.CreateDescriptorPool(bound_state.device, &descriptor_pool_create_info, nil, descriptor_pool); if res != .SUCCESS {
        log.error("Failed to create descriptor pool:", res)
        return false
    }

    return true
}

// Handles do not need to be destroyed, automatically freed when corresponding descriptor pool is destroyed
allocate_descriptor_sets :: proc(descriptor_pool: vk.DescriptorPool, descriptor_set_layout: vk.DescriptorSetLayout, descriptor_sets: ^[dynamic]vk.DescriptorSet) -> (ok: bool) {
    using bound_state
    resize(descriptor_sets, config.RENDERER_FRAMES_IN_FLIGHT)
   
    descriptor_set_layouts := make([]vk.DescriptorSetLayout, config.RENDERER_FRAMES_IN_FLIGHT)
    defer delete(descriptor_set_layouts)
    for i in 0..<config.RENDERER_FRAMES_IN_FLIGHT {
        descriptor_set_layouts[i] = descriptor_set_layout
    }

    descriptor_set_alloc_info: vk.DescriptorSetAllocateInfo = {
        sType = .DESCRIPTOR_SET_ALLOCATE_INFO,
        descriptorPool = descriptor_pool,
        descriptorSetCount = u32(config.RENDERER_FRAMES_IN_FLIGHT),
        pSetLayouts = raw_data(descriptor_set_layouts),
    }


    res := vk.AllocateDescriptorSets(device, &descriptor_set_alloc_info, raw_data(descriptor_sets^)); if res != .SUCCESS {
        log.error("Failed to allocate descriptor sets:", res)
        return false
    }

    return true
}
