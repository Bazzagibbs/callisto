package callisto_engine_renderer_vulkan

import "core:log"
import "core:strings"
import "core:math"
import "core:os"
when config.BUILD_TARGET == .Desktop do import "vendor:glfw"
import vk "vendor:vulkan"
import "../../../config"
import "../../window"

validation_layers := [?]cstring {
    "VK_LAYER_KHRONOS_validation",
}

required_instance_extensions : [dynamic]cstring = {
    vk.KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME,
}

required_device_extensions : [dynamic]cstring = {
    vk.KHR_SWAPCHAIN_EXTENSION_NAME,
}

dynamic_states: [dynamic]vk.DynamicState = {
    .VIEWPORT,
    .SCISSOR,
}

get_global_proc_address :: proc(p: rawptr, name: cstring) {
    when config.BUILD_TARGET == .Desktop {
        (^rawptr)(p)^ = glfw.GetInstanceProcAddress(nil, name)
    }
}

create_instance :: proc() -> (instance: vk.Instance, ok: bool) {
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
    
    app_info : vk.ApplicationInfo = {
        sType = vk.StructureType.APPLICATION_INFO,
        pApplicationName = cstring(config.APP_NAME),
        applicationVersion = vk.MAKE_VERSION(config.APP_VERSION[0], config.APP_VERSION[1], config.APP_VERSION[2]),
        pEngineName = "Callisto",
        engineVersion = vk.MAKE_VERSION(config.ENGINE_VERSION[0], config.ENGINE_VERSION[1], config.ENGINE_VERSION[2]),
        apiVersion = vk.MAKE_VERSION(1, 1, 0),
    }
    
    instance_info : vk.InstanceCreateInfo = {
        sType = vk.StructureType.INSTANCE_CREATE_INFO,
        pApplicationInfo = &app_info,
        flags = {.ENUMERATE_PORTABILITY_KHR},
        enabledExtensionCount = u32(len(required_instance_extensions)),
        ppEnabledExtensionNames = raw_data(required_instance_extensions),
    }

    when config.ENGINE_DEBUG {
        init_logger()
        if check_validation_layer_support(validation_layers[:]) == false {
            log.fatal("Requested Vulkan validation layer not available")
            return {}, false
        }

        // debug_create_info := vk_impl.debug_messenger_create_info() 
        // instance_info.pNext = &debug_create_info
        instance_info.enabledLayerCount = len(validation_layers)
        instance_info.ppEnabledLayerNames = &validation_layers[0]
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

create_debug_messenger :: proc(state: ^State) -> (messenger: vk.DebugUtilsMessengerEXT, ok: bool) {
    when config.ENGINE_DEBUG {
        // create debug messenger
        debug_create_info := debug_messenger_create_info() 
        res := vk.CreateDebugUtilsMessengerEXT(state.instance, &debug_create_info, nil, &messenger); if res != .SUCCESS {
            log.fatal("Error creating debug messenger:", res)
            return {}, false
        }
        defer if !ok do vk.DestroyDebugUtilsMessengerEXT(state.instance, messenger, nil)
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

create_surface :: proc(state: ^State) -> (surface: vk.SurfaceKHR, ok: bool) {
    when config.BUILD_TARGET == .Desktop {
        res := glfw.CreateWindowSurface(state.instance, glfw.WindowHandle(window.handle), nil, &surface); if res != .SUCCESS {
            log.fatal("Failed to create window surface:", res)
            return {}, false
        }
        ok = true
        return
    }

    log.fatal("Platform not supported:", config.BUILD_TARGET)
    return {}, false
}

select_physical_device :: proc(state: ^State) -> (physical_device: vk.PhysicalDevice, ok: bool) {
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
        return {}, false
    }
    

    return highest_device, true
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

create_logical_device :: proc(state: ^State) -> (logical_device: vk.Device, queue_family_indices: Queue_Family_Indices, queue_handles: Queue_Handles, ok: bool) {
    queue_family_indices = find_queue_family_indices(state.physical_device, state.surface)

    // Queue families may have the same index. Only create one queue in this case.
    unique_indices_set := make(map[u32]struct{})
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
        sType = .DEVICE_CREATE_INFO,
        queueCreateInfoCount = u32(len(queue_create_infos)),
        pQueueCreateInfos = raw_data(queue_create_infos),
        pEnabledFeatures = &features,
        enabledExtensionCount = u32(len(required_device_extensions)),
        ppEnabledExtensionNames = raw_data(required_device_extensions),
    } 

    when config.ENGINE_DEBUG {
        device_create_info.enabledLayerCount = len(validation_layers)
        device_create_info.ppEnabledLayerNames = &validation_layers[0]
    }

    res := vk.CreateDevice(state.physical_device, &device_create_info, nil, &logical_device); if res != .SUCCESS {
        log.fatal("Failed to create logical device:", res)
        return {}, {}, {}, false
    }

    vk.GetDeviceQueue(logical_device, queue_family_indices.graphics.?, 0, &queue_handles.graphics)    
    vk.GetDeviceQueue(logical_device, queue_family_indices.present.?, 0, &queue_handles.present)

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

create_swapchain :: proc(state: ^State) -> (swapchain: vk.SwapchainKHR, swapchain_details: Swapchain_Details, ok: bool) {
    swapchain_details, ok = select_swapchain_details(state); if !ok {
        log.fatal("Swapchain is not suitable")
    }

    image_count: u32 = swapchain_details.capabilities.minImageCount + 1

    if swapchain_details.capabilities.maxImageCount > 0 && image_count > swapchain_details.capabilities.maxImageCount {
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
    indices_values := [?]u32 {indices.graphics.?, indices.present.?}    
    if indices.graphics.? == indices.present.? {
        swapchain_create_info.imageSharingMode = .EXCLUSIVE
        swapchain_create_info.queueFamilyIndexCount = 2
        swapchain_create_info.pQueueFamilyIndices = &indices_values[0]
    }
    else {
        swapchain_create_info.imageSharingMode = .CONCURRENT
    }

    res := vk.CreateSwapchainKHR(state.device, &swapchain_create_info, nil, &swapchain); if res != .SUCCESS {
        log.fatal("Failed to create swapchain:", res)
        return {}, {}, false
    }

    ok = true
    return
}

select_swapchain_details :: proc(state: ^State) -> (details: Swapchain_Details, ok: bool) {
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

get_images :: proc(state: ^State, images: ^[dynamic]vk.Image) {
    image_count: u32
    vk.GetSwapchainImagesKHR(state.device, state.swapchain, &image_count, nil)
    resize(images, int(image_count))
    vk.GetSwapchainImagesKHR(state.device, state.swapchain, &image_count, raw_data(images^))
}

create_image_views :: proc(state: ^State, image_views: ^[dynamic]vk.ImageView) -> (ok: bool) {
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
            for j in 0..<i {
                vk.DestroyImageView(state.device, image_views[j], nil)
            }
            return false
        }
    }
    return true
}

destroy_image_views :: proc(state: ^State, image_views: ^[dynamic]vk.ImageView) {
    for image_view in image_views {
        vk.DestroyImageView(state.device, image_view, nil)
    }

    resize(image_views, 0)
}

create_render_pass :: proc(state: ^State) -> (render_pass: vk.RenderPass, ok: bool) {
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
        layout = .COLOR_ATTACHMENT_OPTIMAL,
    }

    subpass_desc: vk.SubpassDescription = {
        pipelineBindPoint = .GRAPHICS,
        colorAttachmentCount = 1,
        pColorAttachments = &color_attachment_ref,
    }

    render_pass_create_info: vk.RenderPassCreateInfo = {
        sType = .RENDER_PASS_CREATE_INFO,
        attachmentCount = 1,
        pAttachments = &color_attachment_desc,
        subpassCount = 1,
        pSubpasses = &subpass_desc,
        dependencyCount = 1,
        pDependencies = &subpass_dependency,
    }

    res := vk.CreateRenderPass(state.device, &render_pass_create_info, nil, &render_pass); if res != .SUCCESS {
        log.fatal("Failed to create render pass:", res)
        return {}, false
    }

    ok = true
    return
}

create_graphics_pipeline :: proc(state: ^State) -> (pipeline: vk.Pipeline, pipeline_layout: vk.PipelineLayout, ok: bool) {
    vert_file, err1 := os.open("callisto/assets/shaders/vert.spv");
    defer os.close(vert_file)
    frag_file, err2 := os.open("callisto/assets/shaders/frag.spv");
    defer os.close(frag_file)
    if err1 != os.ERROR_NONE || err2 != os.ERROR_NONE { 
        log.error("Failed to open file")
        return {}, {}, false
    }

    vert_module := create_shader_module(state.device, vert_file) or_return
    defer vk.DestroyShaderModule(state.device, vert_module, nil)
    frag_module := create_shader_module(state.device, frag_file) or_return
    defer vk.DestroyShaderModule(state.device, frag_module, nil)

    shader_stages := [?]vk.PipelineShaderStageCreateInfo {
        // Vertex
        {
            sType = .PIPELINE_SHADER_STAGE_CREATE_INFO,
            stage = {.VERTEX},
            module = vert_module,
            pName = "main",
        },
        // Fragment
        {
            sType = .PIPELINE_SHADER_STAGE_CREATE_INFO,
            stage = {.FRAGMENT},
            module = frag_module,
            pName = "main",
        },
    }

    dynamic_state_create_info: vk.PipelineDynamicStateCreateInfo = {
        sType = .PIPELINE_DYNAMIC_STATE_CREATE_INFO,
        dynamicStateCount = u32(len(dynamic_states)),
        pDynamicStates = raw_data(dynamic_states),
    }

    vertex_input_state_create_info: vk.PipelineVertexInputStateCreateInfo = {
        sType = .PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
        vertexBindingDescriptionCount = 0,
        vertexAttributeDescriptionCount = 0,
    }

    input_assembly_state_create_info: vk.PipelineInputAssemblyStateCreateInfo = {
        sType = .PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
        topology = .TRIANGLE_LIST,
        primitiveRestartEnable = false,
    }

    viewport: vk.Viewport = {
        x = 0,
        y = 0,
        width = f32(state.swapchain_details.extent.width),
        height = f32(state.swapchain_details.extent.height),
        minDepth = 0,
        maxDepth = 1,
    }

    scissor: vk.Rect2D = {
        offset = {0, 0},
        extent = state.swapchain_details.extent,
    }

    viewport_state_create_info: vk.PipelineViewportStateCreateInfo = {
        sType = .PIPELINE_VIEWPORT_STATE_CREATE_INFO,
        viewportCount = 1,
        pViewports = &viewport,
        scissorCount = 1,
        pScissors = &scissor,
    }

    rasterizer_state_create_info: vk.PipelineRasterizationStateCreateInfo = {
        sType = .PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
        depthClampEnable = false,
        rasterizerDiscardEnable = false,
        lineWidth = 1,
        cullMode = {.BACK},
        frontFace = .CLOCKWISE,
        depthBiasEnable = false,
    }

    multisample_state_create_info: vk.PipelineMultisampleStateCreateInfo = {
        sType = .PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
        rasterizationSamples = {._1},
        sampleShadingEnable = false,
    }

    color_blend_attachment_state: vk.PipelineColorBlendAttachmentState = {
        blendEnable = false,
        colorWriteMask = {.R, .G, .B, .A},
    }
    
    color_blend_state_create_info: vk.PipelineColorBlendStateCreateInfo = {
        sType = .PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
        logicOpEnable = false,
        logicOp = .COPY,
        attachmentCount = 1,
        pAttachments = &color_blend_attachment_state,
    }

    pipeline_layout_create_info: vk.PipelineLayoutCreateInfo = {
        sType = .PIPELINE_LAYOUT_CREATE_INFO,
    }

    res := vk.CreatePipelineLayout(state.device, &pipeline_layout_create_info, nil, &pipeline_layout); if res != .SUCCESS {
        log.fatal("Error creating pipeline layout:", res)
        ok = false
        return
    }
    defer if !ok do vk.DestroyPipelineLayout(state.device, pipeline_layout, nil)


    pipeline_create_info: vk.GraphicsPipelineCreateInfo = {
        sType = .GRAPHICS_PIPELINE_CREATE_INFO,
        stageCount = 2,
        pStages = &shader_stages[0],
        pVertexInputState = &vertex_input_state_create_info,
        pInputAssemblyState = &input_assembly_state_create_info,
        pViewportState = &viewport_state_create_info,
        pRasterizationState = &rasterizer_state_create_info,
        pMultisampleState = &multisample_state_create_info,
        pDepthStencilState = nil,
        pColorBlendState = &color_blend_state_create_info,
        pDynamicState = &dynamic_state_create_info,
        
        layout = pipeline_layout,
        renderPass = state.render_pass,
        subpass = 0,
    }

    res = vk.CreateGraphicsPipelines(state.device, 0, 1, &pipeline_create_info, nil, &pipeline); if res != .SUCCESS {
        log.fatal("Error creating graphics pipeline:", res)
        ok = false
        return
    }

    ok = true
    return
}

create_shader_module :: proc(device: vk.Device, file: os.Handle) -> (module: vk.ShaderModule, ok: bool) {
    module_source, ok1 := os.read_entire_file(file); if !ok1 {
        log.error("Failed to create shader module: Could not read file")
        return {}, false
    }
    defer delete(module_source)

    module_info: vk.ShaderModuleCreateInfo = {
        sType = .SHADER_MODULE_CREATE_INFO,
        codeSize = len(module_source),
        pCode = transmute(^u32)raw_data(module_source), // yuck
    }

    res := vk.CreateShaderModule(device, &module_info, nil, &module); if res != .SUCCESS {
        log.error("Failed to create shader module")
        return {}, false
    }

    ok = true
    return
}

create_framebuffers :: proc(state: ^State, framebuffers: ^[dynamic]vk.Framebuffer) -> (ok: bool) {
    resize(framebuffers, len(state.image_views))

    for i in 0..<len(state.image_views) {
        framebuffer_create_info: vk.FramebufferCreateInfo = {
            sType = .FRAMEBUFFER_CREATE_INFO,
            renderPass = state.render_pass,
            attachmentCount = 1,
            pAttachments = &state.image_views[i],
            width = state.swapchain_details.extent.width,
            height = state.swapchain_details.extent.height,
            layers = 1,
        }

        res := vk.CreateFramebuffer(state.device, &framebuffer_create_info, nil, &framebuffers[i]); if res != .SUCCESS {
            log.fatal("Failed to create framebuffers:", res)
            for j in 0..<i {
                vk.DestroyFramebuffer(state.device, framebuffers[j], nil)
            }
            return false
        }
    }
    ok = true
    return
}

destroy_framebuffers :: proc(state: ^State, framebuffer_array: ^[dynamic]vk.Framebuffer) {
    for framebuffer in framebuffer_array {
        vk.DestroyFramebuffer(state.device, framebuffer, nil)
    }

    resize(framebuffer_array, 0)
}

create_command_pool :: proc(state: ^State) -> (command_pool: vk.CommandPool, ok: bool) {
    command_pool_create_info: vk.CommandPoolCreateInfo = {
        sType = .COMMAND_POOL_CREATE_INFO,
        flags = {.RESET_COMMAND_BUFFER},
        queueFamilyIndex = state.queue_family_indices.graphics.?,
    }

    res := vk.CreateCommandPool(state.device, &command_pool_create_info, nil, &command_pool); if res != .SUCCESS {
        log.fatal("Failed to create command pool:", res)
        return {}, false
    }

    ok = true
    return
}

create_command_buffer :: proc(state: ^State) -> (command_buffer: vk.CommandBuffer, ok: bool) {
    command_buffer_allocate_info: vk.CommandBufferAllocateInfo = {
        sType = .COMMAND_BUFFER_ALLOCATE_INFO,
        commandPool = state.command_pool,
        level = .PRIMARY,
        commandBufferCount = 1,
    }

    res := vk.AllocateCommandBuffers(state.device, &command_buffer_allocate_info, &command_buffer); if res != .SUCCESS {
        log.fatal("Failed to allocate command buffer:", res)
        return {}, false
    }

    ok = true
    return
}

record_command_buffer :: proc(state: ^State, command_buffer: vk.CommandBuffer) -> (ok: bool) {
    begin_info: vk.CommandBufferBeginInfo = {
        sType = .COMMAND_BUFFER_BEGIN_INFO,
        flags = {},
    }

    res := vk.BeginCommandBuffer(command_buffer, &begin_info); if res != .SUCCESS {
        log.fatal("Failed to begin recording command buffer:", res)
        return false
    }

    clear_color: vk.ClearValue = { color = { float32 = {0, 0, 0, 1}}}

    render_pass_begin_info: vk.RenderPassBeginInfo = {
        sType = .RENDER_PASS_BEGIN_INFO,
        renderPass = state.render_pass,
        framebuffer = state.framebuffers[state.target_image_index],
        renderArea = {
            offset = {0, 0},
            extent = state.swapchain_details.extent,
        },
        clearValueCount = 1,
        pClearValues = &clear_color,
    }

    vk.CmdBeginRenderPass(command_buffer, &render_pass_begin_info, .INLINE) // Switch to SECONDARY_command_bufferS later
    vk.CmdBindPipeline(command_buffer, .GRAPHICS, state.pipeline)

    viewport: vk.Viewport = {
        x = 0,
        y = 0,
        width = f32(state.swapchain_details.extent.width),
        height = f32(state.swapchain_details.extent.height),
        minDepth = 0,
        maxDepth = 1,
    }

    vk.CmdSetViewport(command_buffer, 0, 1, &viewport)

    scissor: vk.Rect2D = {
        offset = {0, 0},
        extent = state.swapchain_details.extent,
    }

    vk.CmdSetScissor(command_buffer, 0, 1, &scissor)

    vk.CmdDraw(command_buffer, 3, 1, 0, 0);

    vk.CmdEndRenderPass(command_buffer)

    res = vk.EndCommandBuffer(command_buffer); if res != .SUCCESS {
        log.fatal("Failed to record command buffer:", res)
        return false
    }

    return true
}

create_semaphore :: proc(state: ^State) -> (semaphore: vk.Semaphore, ok: bool) {
    semaphore_create_info: vk.SemaphoreCreateInfo = {
        sType = .SEMAPHORE_CREATE_INFO,
    }
    res := vk.CreateSemaphore(state.device, &semaphore_create_info, nil, &semaphore); if res != .SUCCESS {
        log.fatal("Failed to create sempahore:", res)
        return {}, false
    }
    ok = true
    return
}

create_fence :: proc(state: ^State) -> (fence: vk.Fence, ok: bool) {
    fence_create_info: vk.FenceCreateInfo = {
        sType = .FENCE_CREATE_INFO,
        flags = {.SIGNALED},
    }
    res := vk.CreateFence(state.device, &fence_create_info, nil, &fence); if res != .SUCCESS {
        log.fatal("Failed to create fence:", res)
        return {}, false
    }
    ok = true
    return
}


submit_command_buffer :: proc(state: ^State, command_buffer: vk.CommandBuffer) -> (ok: bool) {
    // Replace with arrays if required
    wait_semaphores := state.semaphore_image_available
    signal_semaphores := state.semaphore_render_finished
    command_buffers := command_buffer
    swapchains := state.swapchain
    image_indices := state.target_image_index

    stage_flags := [?]vk.PipelineStageFlags{
        {.COLOR_ATTACHMENT_OUTPUT},
    }

    submit_info: vk.SubmitInfo = {
        sType = .SUBMIT_INFO,
        waitSemaphoreCount = 1,
        pWaitSemaphores = &wait_semaphores,
        pWaitDstStageMask = &stage_flags[0],
        commandBufferCount = 1,
        pCommandBuffers = &command_buffers,
        signalSemaphoreCount = 1,
        pSignalSemaphores = &signal_semaphores,
    }

    res := vk.QueueSubmit(state.queues.graphics, 1, &submit_info, state.fence_in_flight); if res != .SUCCESS {
        log.fatal("Failed to submit command buffer:", res)
        return false
    }
    
    present_info: vk.PresentInfoKHR = {
        sType = .PRESENT_INFO_KHR,
        waitSemaphoreCount = 1,
        pWaitSemaphores = &signal_semaphores,
        swapchainCount = 1,
        pSwapchains = &swapchains,
        pImageIndices = &image_indices,
    }

    res = vk.QueuePresentKHR(state.queues.graphics, &present_info); if res != .SUCCESS {
        switch {
            case res == .ERROR_OUT_OF_DATE_KHR:
                fallthrough
            case res == .SUBOPTIMAL_KHR:
                ok = recreate_swapchain(state, &state.swapchain, &state.swapchain_details, &state.image_views, &state.framebuffers); if !ok {
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

recreate_swapchain :: proc(state: ^State, swapchain: ^vk.SwapchainKHR, swapchain_details: ^Swapchain_Details, image_views: ^[dynamic]vk.ImageView, framebuffers: ^[dynamic]vk.Framebuffer) -> (ok: bool) {
    vk.DeviceWaitIdle(state.device)
    
    destroy_framebuffers(state, framebuffers)
    destroy_image_views(state, image_views)
    vk.DestroySwapchainKHR(state.device, swapchain^, nil)
    
    swapchain^, swapchain_details^ = create_swapchain(state) or_return
    defer if !ok do vk.DestroySwapchainKHR(state.device, swapchain^, nil)
    create_image_views(state, image_views) or_return
    defer if !ok do destroy_image_views(state, image_views)
    create_framebuffers(state, framebuffers) or_return
    // defer if !ok do destroy_framebuffers(state, framebuffers)
    
    ok = true
    return
}