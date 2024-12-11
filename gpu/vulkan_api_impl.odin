#+ private

package callisto_gpu

import dd "vendor:vulkan" // Only used for autocomplete, then replace with `d.<proc>`

import "base:runtime"
import "core:dynlib"
import "core:sync"
import "core:log"
import "core:strings"
import "core:os/os2"
import "core:path/filepath"
import vk "vulkan"
import "vma"
import "../common"
import "../config"

// when RHI == "vulkan" {

LAYERS :: []cstring {
        "VK_LAYER_KHRONOS_shader_object",
}

INSTANCE_EXTENSIONS :: []cstring {
        vk.KHR_SURFACE_EXTENSION_NAME,
}

DEVICE_EXTENSIONS :: []cstring {
        vk.KHR_SWAPCHAIN_EXTENSION_NAME,
}


_device_init :: proc(d: ^Device, init_info: ^Device_Init_Info, location := #caller_location) -> (res: Result) {
        log.info("Initializing Device")

        validate_info(location,
                Valid_Not_Nil{".runner", init_info.runner},
        ) or_return


        _vk_loader(d)
        _vk_instance_init(d, init_info) or_return
        _vk_physical_device_select(d, init_info) or_return
        _vk_device_init(d, init_info) or_return
        _vk_vma_init(d) or_return

        return .Ok
}


_device_destroy :: proc(d: ^Device) {
        log.info("Destroying Device")

        d.DeviceWaitIdle(d.device)

        _vk_vma_destroy(d)
        _vk_device_destroy(d)
        _vk_instance_destroy(d)
}


_swapchain_init :: proc(d: ^Device, sc: ^Swapchain, init_info: ^Swapchain_Init_Info, location := #caller_location) -> (res: Result) {
        log.info("Initializing Swapchain")

        validate_info(location, 
                Valid_Not_Nil{".window", init_info.window}
        ) or_return

        _vk_surface_init(d, sc, init_info) or_return
        _vk_swapchain_init(d, sc, init_info) or_return
        _vk_swapchain_images_init(d, sc) or_return
        _vk_swapchain_sync_init(d, sc) or_return
        _vk_swapchain_command_buffers_init(d, sc) or_return

        return .Ok
}


_swapchain_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        log.info("Destroying Swapchain")
        
        d.DeviceWaitIdle(d.device)
       
        _vk_swapchain_command_buffers_destroy(d, sc)
        _vk_swapchain_sync_destroy(d, sc)
        _vk_swapchain_images_destroy(d, sc)
        _vk_swapchain_destroy(d, sc)
        _vk_surface_destroy(d, sc)
}

// swapchain_rebuild             :: proc(d: ^Device, sc: ^Swapchain) -> (res: Result)
// swapchain_set_vsync           :: proc(d: ^Device, sc: ^Swapchain, vsync: Vsync_Mode) -> (res: Result)
// swapchain_get_vsync           :: proc(d: ^Device, sc: ^Swapchain) -> (vsync: Vsync_Mode)
// swapchain_get_available_vsync :: proc(d: ^Device, sc: ^Swapchain) -> (vsyncs: Vsync_Modes)

_swapchain_wait_for_next_frame :: proc(d: ^Device, sc: ^Swapchain) -> (res: Result) {
        vkres := d.WaitForFences(d.device, 1, &sc.in_flight_fence[sc.frame_counter], false, max(u64))
        check_result(vkres) or_return
        vkres = d.ResetFences(d.device, 1, &sc.in_flight_fence[sc.frame_counter])
        check_result(vkres) or_return
        return .Ok
}

_swapchain_acquire_texture :: proc(d: ^Device, sc: ^Swapchain, texture: ^^Texture) -> (res: Result) {
        if sc.needs_recreate {
                _vk_swapchain_recreate(d, sc) or_return
        }

        vkres := d.AcquireNextImageKHR(d.device, sc.swapchain, max(u64), sc.image_available_sema[sc.frame_counter], {}, &sc.image_index)

        if vkres != .SUCCESS && vkres != .SUBOPTIMAL_KHR {
                // attempt to recreate invalid swapchain
                _vk_swapchain_recreate(d, sc) or_return
        }

        texture^ = &sc.textures[sc.image_index]

        return .Ok
}

_swapchain_acquire_command_buffer :: proc(d: ^Device, sc: ^Swapchain, cb: ^^Command_Buffer) -> (res: Result) {
        cb^ = &sc.command_buffers[sc.frame_counter]

        vkres := d.ResetCommandPool(d.device, cb^.pool, {})
        check_result(vkres) or_return

        return .Ok
}

_swapchain_present :: proc(d: ^Device, sc: ^Swapchain) -> (res: Result) {
        present_info := vk.PresentInfoKHR {
                sType              = .PRESENT_INFO_KHR,
                waitSemaphoreCount = 1,
                pWaitSemaphores    = &sc.render_finished_sema[sc.frame_counter],
                swapchainCount     = 1,
                pSwapchains        = &sc.swapchain,
                pImageIndices      = &sc.image_index
        }

        sc.frame_counter = (sc.frame_counter + 1) % FRAMES_IN_FLIGHT

        vkres := d.QueuePresentKHR(sc.present_queue, &present_info)
        if vkres == .SUBOPTIMAL_KHR {
                return .Ok
        }

        check_result(vkres) or_return

        return .Ok
}


_command_buffer_init :: proc(d: ^Device, cb: ^Command_Buffer, init_info: ^Command_Buffer_Init_Info, location := #caller_location) -> (res: Result) {
        log.info("Creating Command Buffer")
        // validate_info()

        cb.type = init_info.type

        family : u32
        switch cb.type {
        case .Graphics, .Compute_Sync: 
                family = d.graphics_family
        case .Compute_Async:
                family = d.async_compute_family
        }
        
        pool_info := vk.CommandPoolCreateInfo {
                sType            = .COMMAND_POOL_CREATE_INFO,
                flags            = {}, // Might need .RESET here but probably not, just reset the pool
                queueFamilyIndex = family,
        }

        vkres: vk.Result

        vkres = d.CreateCommandPool(d.device, &pool_info, nil, &cb.pool)
        check_result(vkres) or_return
   

        buffer_info := vk.CommandBufferAllocateInfo {
                sType              = .COMMAND_BUFFER_ALLOCATE_INFO,
                commandPool        = cb.pool,
                commandBufferCount = 1,
                level              = .PRIMARY,
        }
        vkres = d.AllocateCommandBuffers(d.device, &buffer_info, &cb.buffer)
        check_result(vkres) or_return

        if init_info.wait_semaphore != nil {
                cb.wait_sema = init_info.wait_semaphore.sema
        }
        if init_info.signal_semaphore != nil {
                cb.signal_sema = init_info.signal_semaphore.sema
        }
        if init_info.signal_fence != nil {
                cb.signal_fence = init_info.signal_fence.fence
        }
        
        return .Ok
}

_command_buffer_destroy :: proc(d: ^Device, cb: ^Command_Buffer) {
        log.info("Destroying Command Buffer")
        
        d.DestroyCommandPool(d.device, cb.pool, nil)
}

_command_buffer_begin :: proc(d: ^Device, cb: ^Command_Buffer) -> (res: Result) {
        begin_info := vk.CommandBufferBeginInfo {
                sType = .COMMAND_BUFFER_BEGIN_INFO,
                flags = {.ONE_TIME_SUBMIT}
        }
        vkres := d.BeginCommandBuffer(cb.buffer, &begin_info)
        return check_result(vkres)
}

_command_buffer_end :: proc(d: ^Device, cb: ^Command_Buffer) -> (res: Result) {
        vkres := d.EndCommandBuffer(cb.buffer)
        return check_result(vkres)
}

_command_buffer_submit :: proc(d: ^Device, cb: ^Command_Buffer) -> (res: Result) {
        queue: vk.Queue

        switch cb.type {
        case .Graphics, .Compute_Sync : queue = d.graphics_queue
        case .Compute_Async           : queue = d.async_compute_queue
        case                          : queue = d.graphics_queue
        }

        cb_info := vk.CommandBufferSubmitInfo {
                sType         = .COMMAND_BUFFER_SUBMIT_INFO,
                commandBuffer = cb.buffer,
                deviceMask    = 0,
        }

        wait_sema_info := vk.SemaphoreSubmitInfo {
                sType       = .SEMAPHORE_SUBMIT_INFO,
                semaphore   = cb.wait_sema,
                stageMask   = {.COLOR_ATTACHMENT_OUTPUT},
                deviceIndex = 0,
                value       = 1,
        }
        
        signal_sema_info := vk.SemaphoreSubmitInfo {
                sType       = .SEMAPHORE_SUBMIT_INFO,
                semaphore   = cb.signal_sema,
                stageMask   = {.ALL_GRAPHICS},
                deviceIndex = 0,
                value       = 1,
        }

        submit_info := vk.SubmitInfo2 {
                sType                    = .SUBMIT_INFO_2,
                waitSemaphoreInfoCount   = 0 if cb.wait_sema == {} else 1,
                pWaitSemaphoreInfos      = &wait_sema_info,
                signalSemaphoreInfoCount = 0 if cb.signal_sema == {} else 1,
                pSignalSemaphoreInfos    = &signal_sema_info,
                commandBufferInfoCount   = 1,
                pCommandBufferInfos      = &cb_info,
        }

        vkres := d.QueueSubmit2(queue, 1, &submit_info, cb.signal_fence)
        return check_result(vkres)
}


_cmd_transition_texture :: proc(d: ^Device, cb: ^Command_Buffer, tex: ^Texture, transition_info: ^Texture_Transition_Info) {
        range := _vk_subresource_range(transition_info.texture_aspect)

        barrier := vk.ImageMemoryBarrier2 {
                sType            = .IMAGE_MEMORY_BARRIER_2,
                srcStageMask     = _vk_pipeline_stages(transition_info.after_src_stages),
                dstStageMask     = _vk_pipeline_stages(transition_info.before_dst_stages),
                srcAccessMask    = _vk_access(transition_info.src_access),
                dstAccessMask    = _vk_access(transition_info.dst_access),
                oldLayout        = _Texture_Layout_To_Vk[transition_info.src_layout],
                newLayout        = _Texture_Layout_To_Vk[transition_info.dst_layout],
                image            = tex.image,
                subresourceRange = range,
        }

        dep_info := vk.DependencyInfo {
                sType                   = .DEPENDENCY_INFO,
                imageMemoryBarrierCount = 1,
                pImageMemoryBarriers    = &barrier,
        }

        d.CmdPipelineBarrier2(cb.buffer, &dep_info)
}


_cmd_clear_color_texture :: proc(d: ^Device, cb: ^Command_Buffer, tex: ^Texture, color: [4]f32) { 
        val := vk.ClearColorValue{float32 = color}
        range := _vk_subresource_range({.Color})
        d.CmdClearColorImage(cb.buffer, tex.image, .GENERAL, &val, 1, &range)
}
/*

buffer_init              :: proc(d: ^Device, b: ^Buffer, init_info: ^Buffer_Init_Info) -> (res: Result)
buffer_destroy           :: proc(d: ^Device, b: ^Buffer)
// buffer_transfer       :: proc(d: ^Device, transfer_info: ^Buffer_Transfer_Info) -> (res: Result)

texture_init             :: proc(d: ^Device, t: ^Texture, init_info: ^Texture_Init_Info) -> (res: Result)
texture_destroy          :: proc(d: ^Device, t: ^Texture)

sampler_init             :: proc(d: ^Device, s: ^Sampler, init_info: ^Sampler_Init_Info) -> (res: Result)
sampler_destroy          :: proc(d: ^Device, s: ^Sampler)

shader_init              :: proc(d: ^Device, s: ^Shader, init_info: ^Shader_Init_Info) -> (res: Result)
shader_destroy           :: proc(d: ^Device, s: ^Shader)

fence_reset              :: proc(d: ^Device, fences:[]^Fence) -> (res: Result)
fence_wait               :: proc(d: ^Device, fences: []^Fence) -> (res: Result)
cmd_fence_signal         :: proc(d: ^Device, fences: []^Fence)
cmd_semaphore_wait       :: proc(d: ^Device, semaphores: []^Semaphore)
cmd_semaphore_signal     :: proc(d: ^Device, semaphores: []^Semaphore)

cmd_set_scissor          :: proc(d: ^Device, cb: ^Command_Buffer, top_left: [2]int, size: [2]int)
cmd_set_viewport         :: proc(d: ^Device, cb: ^Command_Buffer, top_left: [2]int, size: [2]int)
cmd_clear_texture_color  :: proc(d: ^Device, cb: ^Command_Buffer, color: [4]f32)
cmd_clear_texture_depth_stencil  :: proc(d: ^Device, cb: ^Command_Buffer, depth: f32, stencil: u8)
cmd_transition_texture   :: proc(d: ^Device, cb: ^Command_Buffer, texture: ^Texture, src_layout, dst_layout: Texture_Layout)

cmd_set_shaders :: proc(d: ^Device, cb: ^Command_Buffer, shaders: []^Shader)
cmd_set_render_targets :: proc(d: ^Device, cb: ^Command_Buffer, color_target: ^Texture_View, depth_stencil_target: ^Texture_View)
// cmd_set_uniform_buffer :: proc(d: ^Device, cb: ^Command_Buffer, slot: u32, ub: ^Uniform_Buffer)

cmd_draw                 :: proc(d: ^Device, cb: ^Command_Buffer, verts: ^Buffer, indices: ^Buffer)
*/

// ======================================
// UTILS
// ======================================

// NOTE: positive `vkres` can be status codes, not necessarily errors
check_result :: proc(vkres: vk.Result, loc := #caller_location) -> Result {
        
        if vkres == .SUCCESS {
                return .Ok
        }
        
        log.error("RHI:", vkres, loc)
       
        #partial switch vkres {
        case .ERROR_OUT_OF_HOST_MEMORY: return .Out_Of_Memory_CPU
        case .ERROR_OUT_OF_DEVICE_MEMORY: return .Out_Of_Memory_GPU
        case .ERROR_MEMORY_MAP_FAILED: return .Memory_Map_Failed
        }

        return .Unknown_RHI_Error

}

_vk_prepend_layer_path :: proc() -> (ok: bool) {
        when ODIN_OS == .Windows {
                SEP :: ";"
        } else when ODIN_OS == .Linux || ODIN_OS == .Darwin {
                SEP :: ":"
        }
        
        existing := os2.get_env("VK_LAYER_PATH", context.temp_allocator)

        exe_dir := common.get_exe_directory(context.temp_allocator)
        ours := filepath.join({exe_dir, config.SHIPPING_LIBS_PATH, "vulkan"}, context.temp_allocator)

        if existing != "" {
                err: runtime.Allocator_Error
                ours, err = strings.join({ours, existing}, SEP)
                if err != nil {
                        return false
                }
        }

        return os2.set_env("VK_LAYER_PATH", ours)
}


_Aspect_Flag_To_Vk := [Texture_Aspect_Flag]vk.ImageAspectFlag {
        .Color   = .COLOR,
        .Depth   = .DEPTH,
        .Stencil = .STENCIL,
}

_vk_subresource_range :: #force_inline proc(aspect: Texture_Aspect_Flags) -> vk.ImageSubresourceRange {
        mask := vk.ImageAspectFlags {}

        for flag in aspect {
                mask += {_Aspect_Flag_To_Vk[flag]}
        }

        return vk.ImageSubresourceRange {
                aspectMask     = mask,
                baseMipLevel   = 0,
                levelCount     = vk.REMAINING_MIP_LEVELS,
                baseArrayLayer = 0,
                layerCount     = vk.REMAINING_ARRAY_LAYERS,
        }
}


// ======================================
// DEVICE
// ======================================


_vk_instance_init :: proc(d: ^Device, init_info: ^Device_Init_Info) -> (res: Result) {
        log.debug("Creating Vulkan instance")

        app_version := vk.MAKE_VERSION(
                config.APP_VERSION_MAJOR,
config.APP_VERSION_MINOR,
                config.APP_VERSION_PATCH
        )
        engine_version := vk.MAKE_VERSION(
                config.ENGINE_VERSION_MAJOR, 
                config.ENGINE_VERSION_MINOR,
                config.ENGINE_VERSION_PATCH
        )


        app_info := vk.ApplicationInfo {
                sType              = .APPLICATION_INFO,
                pApplicationName   = config.APP_NAME,
                applicationVersion = app_version,
                pEngineName        = "Callisto",
                engineVersion      = engine_version,
                apiVersion         = vk.API_VERSION_1_3,
        }

        // Layers
        layers := make([dynamic]cstring, context.temp_allocator)
        defer delete(layers)

        append(&layers, ..LAYERS)
        
        when VK_VALIDATION_LAYER {
                append(&layers, "VK_LAYER_KHRONOS_validation")
        }
        


        // Instance Extensions
        pNext: rawptr

        instance_extensions := make([dynamic]cstring, context.temp_allocator) 
        append(&instance_extensions, ..INSTANCE_EXTENSIONS)

        when ODIN_OS == .Windows {
                append(&instance_extensions, vk.KHR_WIN32_SURFACE_EXTENSION_NAME)
        }
        
        when VK_VALIDATION_LAYER {
                append(&instance_extensions, vk.EXT_DEBUG_UTILS_EXTENSION_NAME)

                severity : vk.DebugUtilsMessageSeverityFlagsEXT = {.INFO, .WARNING, .ERROR}
                if config.VERBOSE {
                        severity += {.VERBOSE}
                }

                debug_create_info := vk.DebugUtilsMessengerCreateInfoEXT {
                        sType           = .DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
                        messageSeverity = severity,
                        messageType     = {.GENERAL, .VALIDATION, .PERFORMANCE, .DEVICE_ADDRESS_BINDING},
                        pfnUserCallback = init_info.runner.rhi_logger_proc,
                        pUserData       = init_info.runner,
                }

                when VK_ENABLE_INSTANCE_DEBUGGING {
                        pNext_tail^ = &debug_create_info
                        pNext_tail = &debug_create_info.pNext
                }
        }


        if ok := _vk_prepend_layer_path(); ok == false {
                log.error("Could not prepend the Vulkan Layer environment variable")
        }

        log.debugf(" Layers: %#v", layers)
        log.debugf(" Instance extensions: %#v", instance_extensions)

        create_info := vk.InstanceCreateInfo {
                sType                   = .INSTANCE_CREATE_INFO,
                pNext                   = pNext,
                pApplicationInfo        = &app_info,
                enabledLayerCount       = len32(layers),
                ppEnabledLayerNames     = raw_data(layers),
                enabledExtensionCount   = len32(instance_extensions),
                ppEnabledExtensionNames = raw_data(instance_extensions),
        }

        vkres := d.CreateInstance(&create_info, nil, &d.instance)
        check_result(vkres) or_return
        defer if res != nil {
                d.DestroyInstance(d.instance, nil)
        }

        vk.load_proc_addresses_instance_vtable(d.instance, &d.vtable)


        when VK_VALIDATION_LAYER {
                vkres = d.CreateDebugUtilsMessengerEXT(d.instance, &debug_create_info, nil, &d.debug_messenger)
                check_result(vkres) or_return
        }
        
        return .Ok
}


_vk_physical_device_select :: proc(d: ^Device, init_info: ^Device_Init_Info) -> (res: Result) {
        log.debug("Selecting physical device")

        phys_dev_count: u32
        vkres := d.EnumeratePhysicalDevices(d.instance, &phys_dev_count, nil)
        check_result(vkres) or_return

        phys_devices := make([]vk.PhysicalDevice, phys_dev_count, context.temp_allocator)
        defer delete(phys_devices, context.temp_allocator)
        vkres = d.EnumeratePhysicalDevices(d.instance, &phys_dev_count, raw_data(phys_devices))
        check_result(vkres) or_return


        best_index := -1
        best_score := -1
        for pd, i in phys_devices {
                score := _vk_physical_device_score(d, pd, init_info)
                if score > best_score {
                        best_index = i
                        best_score = score
                }
        }

        if best_index == -1 || best_score == -1 {
                log.error("No suitable GPU found!")
                return .No_Suitable_GPU
        }

        log.debug(" Selected physical device", best_index)
        d.phys_device = phys_devices[best_index]

        return .Ok
}


_vk_physical_device_score :: proc(d: ^Device, pd: vk.PhysicalDevice, init_info: ^Device_Init_Info) -> (score: int) {
        properties: vk.PhysicalDeviceProperties
        d.GetPhysicalDeviceProperties(pd, &properties)

        features: vk.PhysicalDeviceFeatures
        d.GetPhysicalDeviceFeatures(pd, &features)

        defer log.debugf(" - [%v] %s", score, properties.deviceName)


        extension_count: u32
        d.EnumerateDeviceExtensionProperties(pd, nil, &extension_count, nil)

        available_extensions := make([]vk.ExtensionProperties, extension_count, context.temp_allocator)
        defer delete(available_extensions, context.temp_allocator)

        d.EnumerateDeviceExtensionProperties(pd, nil, &extension_count, raw_data(available_extensions))

        // required_extensions_by_user := []vk.ExtensionProperties {}

        for req in DEVICE_EXTENSIONS {
                matched := false
                for &avail in available_extensions {
                        if (req == transmute(cstring)(&avail.extensionName)) {
                                matched = true
                                break
                        }
                }

                if matched == false {
                        return -1 // missing extension; not suitable
                }
        }


        score = 0

        if properties.deviceType == .DISCRETE_GPU {
                score += 10_000
        }

        score += int(properties.limits.maxImageDimension2D)

        return 
}


_vk_device_init :: proc(d: ^Device, init_info: ^Device_Init_Info) -> (res: Result) {
        log.debug("Creating Vulkan device")

        count : u32
        d.GetPhysicalDeviceQueueFamilyProperties(d.phys_device, &count, nil)
        queue_family_props := make([]vk.QueueFamilyProperties, count, context.temp_allocator)
        defer delete(queue_family_props, context.temp_allocator)

        d.GetPhysicalDeviceQueueFamilyProperties(d.phys_device, &count, raw_data(queue_family_props))


        unique_queue_families := make(map[u32]struct{}, context.temp_allocator)
        defer delete(unique_queue_families)

        graphics_can_present : bool

        graphics_family      : u32
        compute_family       : u32
        present_family       : u32

        log.debug("  Queue families")

        found_good_queue := false // So we can debug print all the queues
        // Graphics queue
        for props, i in queue_family_props {
                can_present := _vk_query_queue_family_present_support(d, d.phys_device, u32(i)) 
                log.debugf("    - [%v] %v, CanPresent: %v", i, props.queueFlags, can_present)

                if !found_good_queue && props.queueFlags >= {.GRAPHICS, .COMPUTE}  {
                        unique_queue_families[u32(i)] = {}
                        graphics_family = u32(i)
                        compute_family = u32(i)
                        present_family = u32(i)
                        graphics_can_present = can_present 
                        found_good_queue = true
                }
        }

        // Async compute (optional)
        for props, i in queue_family_props {
                if .COMPUTE in props.queueFlags && .GRAPHICS not_in props.queueFlags {
                        unique_queue_families[u32(i)] = {}
                        compute_family = u32(i)
                        break
                }
        }

        // Rare case when graphics queue can't present, just get anything that can
        if !graphics_can_present {
                any_can_present := false
                for props, i in queue_family_props {
                        if _vk_query_queue_family_present_support(d, d.phys_device, u32(i)) {
                                unique_queue_families[u32(i)] = {}
                                present_family = u32(i)
                                break
                        }
                }
                if !any_can_present {
                        log.error("No queue families with Present support!")
                        return .No_Suitable_GPU
                }
        }
        


        log.debug("  Selected queue families")
        log.debug("    - Graphics:     ", graphics_family)
        log.debug("    - Present:      ", present_family)
        log.debug("    - Async compute:", compute_family)

        d.graphics_family      = graphics_family
        d.present_family       = present_family
        d.async_compute_family = compute_family

        queue_priorities : f32 = 1.0
        queue_create_infos := make([dynamic]vk.DeviceQueueCreateInfo, context.temp_allocator)
        defer delete(queue_create_infos)

        for idx in unique_queue_families {
                // Create graphics queue
                queue_info := vk.DeviceQueueCreateInfo {
                        sType            = .DEVICE_QUEUE_CREATE_INFO,
                        queueFamilyIndex = idx,
                        queueCount       = 1,
                        pQueuePriorities = &queue_priorities,
                }

                append(&queue_create_infos, queue_info)
        }


        device_extensions := make([dynamic]cstring, context.temp_allocator)
        defer delete(device_extensions)

        append(&device_extensions, ..DEVICE_EXTENSIONS)
        // append(&device_extensions, ..USER_DEVICE_EXTENSIONS)

        log.debugf("  Device extensions: %#v", device_extensions)


        pNext: rawptr
        // ADD PNEXT FEATURES HERE

        sync2_features := vk.PhysicalDeviceSynchronization2Features {
                sType            = .PHYSICAL_DEVICE_SYNCHRONIZATION_2_FEATURES,
                pNext            = pNext,
                synchronization2 = true,
        }

        pNext = &sync2_features


        device_info := vk.DeviceCreateInfo {
                sType                   = .DEVICE_CREATE_INFO,
                pNext                   = pNext,
                queueCreateInfoCount    = len32(queue_create_infos),
                pQueueCreateInfos       = raw_data(queue_create_infos),
                pEnabledFeatures        = {},
                enabledExtensionCount   = len32(device_extensions),
                ppEnabledExtensionNames = raw_data(device_extensions),
        }

        vkres := d.CreateDevice(d.phys_device, &device_info, nil, &d.device)
        check_result(vkres) or_return

        vk.load_proc_addresses_device_vtable(d.device, &d.vtable)

        // These will sometimes return the same queue, especially queue_present
        d.GetDeviceQueue(d.device, graphics_family, 0, &d.graphics_queue)
        d.GetDeviceQueue(d.device, compute_family, 0, &d.async_compute_queue)
        d.GetDeviceQueue(d.device, present_family, 0, &d.present_queue)

        return .Ok
}


_vk_vma_init :: proc(d: ^Device) -> Result {
        // Is this ok? does vma copy the proc pointers?
        vkfuncs := vma.create_vulkan_functions(&d.vtable)
        create_info := vma.AllocatorCreateInfo {
                flags            = {.BUFFER_DEVICE_ADDRESS},
                physicalDevice   = d.phys_device,
                device           = d.device,
                instance         = d.instance,
                pVulkanFunctions = &vkfuncs,
        }

        vkres := vma.CreateAllocator(&create_info, &d.allocator)
        return check_result(vkres)
}

_vk_vma_destroy :: proc(d: ^Device) {
        vma.DestroyAllocator(d.allocator)
}

_vk_instance_destroy :: proc(d: ^Device) {
        log.debug("Destroying Vulkan instance")
        when VK_VALIDATION_LAYER {
                d.DestroyDebugUtilsMessengerEXT(d.instance, d.debug_messenger, nil)
        }
        d.DestroyInstance(d.instance, nil)
}


_vk_device_destroy :: proc(d: ^Device) {
        log.debug("Destroying Vulkan device")
        d.DestroyDevice(d.device, nil)
}

// ======================================
// SWAPCHAIN
// ======================================

_vk_swapchain_init :: proc(d: ^Device, sc: ^Swapchain, init_info: ^Swapchain_Init_Info, old_swapchain: vk.SwapchainKHR = {}) -> (res: Result) {
        log.debug("Initializing Vulkan Swapchain")

        format: vk.SurfaceFormatKHR
        {
                count: u32
                vkres := d.GetPhysicalDeviceSurfaceFormatsKHR(d.phys_device, sc.surface, &count, nil)
                check_result(vkres) or_return

                avail_formats := make([]vk.SurfaceFormatKHR, int(count), context.temp_allocator)
                vkres = d.GetPhysicalDeviceSurfaceFormatsKHR(d.phys_device, sc.surface, &count, raw_data(avail_formats))
                check_result(vkres) or_return

                // Most common format is r8g8b8a8_srgb
                // HDR goes here!

                format = avail_formats[0] // default to first available
                log.debug("  Available surface formats")
                for f in avail_formats {
                        log.debugf("    - %v %v", f.format, f.colorSpace)
                        if f.format == .R8G8B8A8_SRGB && f.colorSpace == .SRGB_NONLINEAR {
                                format = f
                        }
                }

                log.debugf("  Selected surface format %v %v", format.format, format.colorSpace)
                sc.image_format = format
        }


        present_mode: vk.PresentModeKHR
        {

                requested_present_mode := _vk_vsync_to_present_mode(init_info.vsync)

                count: u32
                vkres := d.GetPhysicalDeviceSurfacePresentModesKHR(d.phys_device, sc.surface, &count, nil)
                check_result(vkres) or_return
                
                avail_present_modes := make([]vk.PresentModeKHR, int(count), context.temp_allocator)
                defer delete(avail_present_modes, context.temp_allocator)
                
                vkres = d.GetPhysicalDeviceSurfacePresentModesKHR(d.phys_device, sc.surface, &count, raw_data(avail_present_modes))
                check_result(vkres) or_return

                present_mode = .FIFO // default to vsync on
                log.debug("  Requested present mode:", requested_present_mode)
                log.debug("  Available present modes")
                for pm in avail_present_modes {
                        log.debugf("    - %v", pm)
                        if pm == requested_present_mode {
                                present_mode = pm
                        }
                }

                log.debugf("  Selected present mode %v", present_mode)
        }


        extent       : vk.Extent2D
        image_count  : u32
        pre_transform : vk.SurfaceTransformFlagsKHR
        {

                capabilities: vk.SurfaceCapabilitiesKHR
                vkres := d.GetPhysicalDeviceSurfaceCapabilitiesKHR(d.phys_device, sc.surface, &capabilities)
                check_result(vkres) or_return
                

                if capabilities.currentExtent.width != max(u32) {
                        extent = capabilities.currentExtent
                } else {
                        // magic number, provide window size
                        window_size := _vk_window_get_size(init_info.window)

                        extent = {
                                width  = clamp(window_size.x, capabilities.minImageExtent.width, capabilities.maxImageExtent.width),
                                height = clamp(window_size.y, capabilities.minImageExtent.height, capabilities.maxImageExtent.height),
                        }

                }
                        
                log.debugf("  Extent: %v, %v", capabilities.currentExtent.width, capabilities.currentExtent.height)
                       

                image_count = capabilities.minImageCount + 1

                // 0 means no maximum
                if capabilities.maxImageCount > 0 {
                        image_count = clamp(image_count, capabilities.minImageCount, capabilities.maxImageCount)
                }
                
                log.debug("  Requested image count:", image_count)

                pre_transform = capabilities.currentTransform
        }

        queue_indices := [2]u32 { d.graphics_family, d.present_family }
        graphics_can_present := d.graphics_family == d.present_family

        swapchain_info := vk.SwapchainCreateInfoKHR {
                sType                 = .SWAPCHAIN_CREATE_INFO_KHR,
                surface               = sc.surface,
                minImageCount         = image_count,
                imageFormat           = format.format,
                imageColorSpace       = format.colorSpace,
                imageExtent           = extent,
                imageArrayLayers      = 1, // VR here!
                imageUsage            = {.COLOR_ATTACHMENT},
                imageSharingMode      = .EXCLUSIVE if graphics_can_present else .CONCURRENT,
                queueFamilyIndexCount = 1 if graphics_can_present else 2,
                pQueueFamilyIndices   = raw_data(&queue_indices),
                preTransform          = pre_transform,
                compositeAlpha        = {.OPAQUE},
                presentMode           = present_mode,
                clipped               = !init_info.force_draw_occluded_fragments,
                oldSwapchain          = old_swapchain,
        }

        if d.graphics_queue == d.present_queue {
                swapchain_info.queueFamilyIndexCount = 1
        }


        vkres := d.CreateSwapchainKHR(d.device, &swapchain_info, nil, &sc.swapchain)
        check_result(vkres) or_return


        return .Ok
}

_vk_swapchain_images_init :: proc(d: ^Device, sc: ^Swapchain) -> Result {
        // Images
        count: u32
        vkres := d.GetSwapchainImagesKHR(d.device, sc.swapchain, &count, nil)
        check_result(vkres) or_return
        log.debug("  Provided image count:", count)

        // ALLOCATION
        sc.textures = make([]Texture, count, context.allocator)

        temp_images := make([]vk.Image, count, context.temp_allocator)
        defer delete(temp_images, context.temp_allocator)

        vkres = d.GetSwapchainImagesKHR(d.device, sc.swapchain, &count, raw_data(temp_images))
        check_result(vkres) or_return

        // Image views
        for i in 0..<count {
                sc.textures[i].image = temp_images[i]

                subresource_range := vk.ImageSubresourceRange {
                        aspectMask     = {.COLOR},
                        baseMipLevel   = 0,
                        levelCount     = 1,
                        baseArrayLayer = 0,
                        layerCount     = 1, // VR here!
                }

                image_view_info := vk.ImageViewCreateInfo {
                        sType            = .IMAGE_VIEW_CREATE_INFO,
                        image            = sc.textures[i].image,
                        viewType         = .D2,
                        format           = sc.image_format.format,
                        components       = {.IDENTITY, .IDENTITY, .IDENTITY, .IDENTITY},
                        subresourceRange = subresource_range,
                }

                vkres = d.CreateImageView(d.device, &image_view_info, nil, &sc.textures[i].full_view.view)
                check_result(vkres) or_return
        }

        return .Ok
}

_vk_swapchain_sync_init :: proc(d: ^Device, sc: ^Swapchain) -> Result {
        fence_create_info := vk.FenceCreateInfo {
                sType = .FENCE_CREATE_INFO,
                flags = {.SIGNALED},
        }

        sema_create_info := vk.SemaphoreCreateInfo {
                sType = .SEMAPHORE_CREATE_INFO,
        }

        for i in 0..<FRAMES_IN_FLIGHT {
                vkres := d.CreateFence(d.device, &fence_create_info, nil, &sc.in_flight_fence[i])
                check_result(vkres) or_return

                vkres = d.CreateSemaphore(d.device, &sema_create_info, nil, &sc.image_available_sema[i])
                check_result(vkres) or_return
                vkres = d.CreateSemaphore(d.device, &sema_create_info, nil, &sc.render_finished_sema[i])
                check_result(vkres) or_return
        }

        when VK_VALIDATION_LAYER {

                @static image_avail_names := [?]cstring {
                        "Image_Available_0",
                        "Image_Available_1",
                        "Image_Available_2",
                }

                @static render_finished_names := [?]cstring {
                        "Render_Finished_0",
                        "Render_Finished_1",
                        "Render_Finished_2",
                }
                
                @static in_flight_names := [?]cstring {
                        "In_Flight_0",
                        "In_Flight_1",
                        "In_Flight_2",
                }

                for i in 0..<FRAMES_IN_FLIGHT {
                        ia_name_info := vk.DebugUtilsObjectNameInfoEXT {
                                sType        = .DEBUG_UTILS_OBJECT_NAME_INFO_EXT,
                                objectType   = .SEMAPHORE,
                                objectHandle = u64(sc.image_available_sema[i]),
                                pObjectName  = image_avail_names[i],
                        }
                        d.SetDebugUtilsObjectNameEXT(d.device, &ia_name_info)
                        
                        rc_name_info := vk.DebugUtilsObjectNameInfoEXT {
                                sType        = .DEBUG_UTILS_OBJECT_NAME_INFO_EXT,
                                objectType   = .SEMAPHORE,
                                objectHandle = u64(sc.render_finished_sema[i]),
                                pObjectName  = render_finished_names[i],
                        }
                        d.SetDebugUtilsObjectNameEXT(d.device, &rc_name_info)
                        
                        if_name_info := vk.DebugUtilsObjectNameInfoEXT {
                                sType        = .DEBUG_UTILS_OBJECT_NAME_INFO_EXT,
                                objectType   = .FENCE,
                                objectHandle = u64(sc.in_flight_fence[i]),
                                pObjectName  = in_flight_names[i],
                        }
                        d.SetDebugUtilsObjectNameEXT(d.device, &if_name_info)
                }
        }

        return .Ok
}

_vk_swapchain_command_buffers_init :: proc(d: ^Device, sc: ^Swapchain) -> Result {
        sc.present_queue = d.present_queue

        for i in 0..<FRAMES_IN_FLIGHT {
                temp_image_available_sema := Semaphore {sc.image_available_sema[i]}
                temp_render_finished_sema := Semaphore {sc.render_finished_sema[i]}
                temp_in_flight_fence      := Fence {sc.in_flight_fence[i]}

                command_buffer_info := Command_Buffer_Init_Info {
                        type             = .Graphics,
                        wait_semaphore   = &temp_image_available_sema,
                        signal_semaphore = &temp_render_finished_sema,
                        signal_fence     = &temp_in_flight_fence,
                }
                command_buffer_init(d, &sc.command_buffers[i], &command_buffer_info) or_return
        }

        return .Ok
}


_vk_vsync_to_present_mode :: proc(vs: Vsync_Mode) -> (pm: vk.PresentModeKHR) {
        switch vs {
        case .Double_Buffered : return .FIFO
        case .Triple_Buffered : return .MAILBOX
        case .Off             : return .IMMEDIATE,
        }

        return .FIFO
}

_vk_swapchain_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        d.DestroySwapchainKHR(d.device, sc.swapchain, nil)
}

_vk_swapchain_images_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        for tex in sc.textures {
                d.DestroyImageView(d.device, tex.full_view.view, nil)
        }

        delete(sc.textures)
}

_vk_swapchain_sync_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        for i in 0..<FRAMES_IN_FLIGHT {
                d.DestroySemaphore(d.device, sc.image_available_sema[i], nil)
                d.DestroySemaphore(d.device, sc.render_finished_sema[i], nil)
                d.DestroyFence(d.device, sc.in_flight_fence[i], nil)
        }
}

_vk_swapchain_command_buffers_destroy :: proc(d: ^Device, sc: ^Swapchain) {
        for i in 0..<FRAMES_IN_FLIGHT {
                d.DestroyCommandPool(d.device, sc.command_buffers[i].pool, nil)
        }
}


_vk_swapchain_recreate :: proc(d: ^Device, sc: ^Swapchain) -> (res: Result) {
        log.info("Recreating Vulkan swapchain")
        // This is a naive implementation - should probably build a new swapchain
        // and wait for the old swapchain's final present before destroying it.
        vkres := d.DeviceWaitIdle(d.device)
        check_result(vkres) or_return

        info := Swapchain_Init_Info {
                window                        = sc.window,
                vsync                         = sc.vsync,
                force_draw_occluded_fragments = sc.force_draw_occluded,
        }

        _vk_swapchain_destroy(d, sc)
        return _vk_swapchain_init(d, sc, &info)
}


// ======================================
// COMMANDS
// ======================================

_Pipeline_Stage_To_Vk := [Pipeline_Stage]vk.PipelineStageFlag2 {
        .Begin                          = .TOP_OF_PIPE,
        .Draw_Indirect                  = .DRAW_INDIRECT,
        .Vertex_Input                   = .VERTEX_INPUT,
        .Vertex_Shader                  = .VERTEX_SHADER,
        .Tessellation_Control_Shader    = .TESSELLATION_CONTROL_SHADER,
        .Tessellation_Evaluation_Shader = .TESSELLATION_EVALUATION_SHADER,
        .Geometry_Shader                = .GEOMETRY_SHADER,
        .Fragment_Shader                = .FRAGMENT_SHADER,
        .Fragment_Early_Tests           = .EARLY_FRAGMENT_TESTS,
        .Fragment_Late_Tests            = .LATE_FRAGMENT_TESTS,
        .Color_Target_Output            = .COLOR_ATTACHMENT_OUTPUT,
        .Compute_Shader                 = .COMPUTE_SHADER,
        .Transfer                       = .TRANSFER,
        .End                            = .BOTTOM_OF_PIPE,
}

_vk_pipeline_stages :: proc(ps: Pipeline_Stages) -> vk.PipelineStageFlags2 {
        flags := vk.PipelineStageFlags2 {}

        for flag in ps {
                flags += {_Pipeline_Stage_To_Vk[flag]}
        }
        return flags
}

_Access_Flag_To_Vk := [Access_Flag]vk.AccessFlag2 {
        .Indirect_Read              = .INDIRECT_COMMAND_READ,
        .Index_Read                 = .INDEX_READ,
        .Vertex_Attribute_Read      = .VERTEX_ATTRIBUTE_READ,
        .Uniform_Read               = .UNIFORM_READ,
        .Texture_Read               = .SHADER_SAMPLED_READ,
        .Texture_Write              = .SHADER_WRITE,
        .Storage_Read               = .SHADER_STORAGE_READ,
        .Storage_Write              = .SHADER_STORAGE_WRITE,
        .Color_Input_Read           = .COLOR_ATTACHMENT_READ,
        .Color_Target_Write         = .COLOR_ATTACHMENT_WRITE,
        .Depth_Stencil_Input_Read   = .DEPTH_STENCIL_ATTACHMENT_READ,
        .Depth_Stencil_Target_Write = .DEPTH_STENCIL_ATTACHMENT_WRITE,
        .Transfer_Read              = .TRANSFER_READ,
        .Transfer_Write             = .TRANSFER_WRITE,
        .Host_Read                  = .HOST_READ,
        .Host_Write                 = .HOST_WRITE,
        
        .Memory_Read                = .MEMORY_READ, // same as setting all `*_Read` bits
        .Memory_Write               = .MEMORY_WRITE, // same as setting all `*_Write` bits

}

_vk_access :: proc(access: Access_Flags) -> vk.AccessFlags2 {
        access := access
        flags := vk.AccessFlags2 {}

        for flag in access {
                flags += {_Access_Flag_To_Vk[flag]}
        }
        return flags
}

_Texture_Layout_To_Vk := [Texture_Layout]vk.ImageLayout {
        .Undefined       = .UNDEFINED,
        .General         = .GENERAL,
        .Target_Or_Input = .ATTACHMENT_OPTIMAL,
        .Read_Only       = .READ_ONLY_OPTIMAL,
        .Transfer_Source = .TRANSFER_SRC_OPTIMAL,
        .Transfer_Dest   = .TRANSFER_DST_OPTIMAL,
        .Pre_Initialized = .PREINITIALIZED,
        .Present         = .PRESENT_SRC_KHR,
}


// } // when RHI == "vulkan"
