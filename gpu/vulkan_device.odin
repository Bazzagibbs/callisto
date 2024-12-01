package callisto_gpu

import vk "../vendor_mod/vulkan"
import "../config"
import "core:log"
import "core:sync"
import "core:strings"

// when RHI == "vulkan"

VK_VALIDATION_LAYER :: ODIN_DEBUG

VK_ENABLE_INSTANCE_DEBUGGING :: true


LAYERS :: []cstring {
        "VK_LAYER_KHRONOS_shader_object",
}

INSTANCE_EXTENSIONS :: []cstring {
        vk.KHR_SURFACE_EXTENSION_NAME,
}

DEVICE_EXTENSIONS :: []cstring {
        vk.KHR_SWAPCHAIN_EXTENSION_NAME,
}


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
        pNext : rawptr = nil

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
                        pNext = &debug_create_info
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

        // Graphics queue
        for props, i in queue_family_props {
                can_present := _vk_query_queue_family_present_support(d, d.phys_device, u32(i)) 
                log.debugf("    - [%v] %v, CanPresent: %v", i, props.queueFlags, can_present)

                // The good queue
                if props.queueFlags >= {.GRAPHICS, .COMPUTE}  {
                        unique_queue_families[u32(i)] = {}
                        graphics_family = u32(i)
                        compute_family = u32(i)
                        present_family = u32(i)
                        graphics_can_present = can_present 
                        break
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
        log.debug("    - Present:      ", graphics_family)
        log.debug("    - Async compute:", graphics_family)

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

        log.debugf(" Device extensions: %#v", device_extensions)

        device_info := vk.DeviceCreateInfo {
                sType = .DEVICE_CREATE_INFO,
                queueCreateInfoCount = len32(queue_create_infos),
                pQueueCreateInfos = raw_data(queue_create_infos),
                pEnabledFeatures = {},
                enabledExtensionCount = len32(device_extensions),
                ppEnabledExtensionNames = raw_data(device_extensions),
        }

        vkres := d.CreateDevice(d.phys_device, &device_info, nil, &d.device)
        check_result(vkres) or_return

        vk.load_proc_addresses_device_vtable(d.device, &d.vtable)

        // These will sometimes return the same queue, especially queue_present
        d.GetDeviceQueue(d.device, graphics_family, 0, &d.queue_graphics)
        d.GetDeviceQueue(d.device, compute_family, 0, &d.queue_async_compute)
        d.GetDeviceQueue(d.device, present_family, 0, &d.queue_present)

        return .Ok
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


