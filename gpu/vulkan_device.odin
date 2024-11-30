package callisto_gpu

import vk "../vendor_mod/vulkan"
import "../config"
import "core:log"
import "core:sync"

// when RHI == "vulkan"

VK_VALIDATION_LAYER :: ODIN_DEBUG

VK_ENABLE_INSTANCE_DEBUGGING :: true


_vk_instance_init :: proc(d: ^Device, init_info: ^Device_Init_Info) -> (res: Result) {

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


        pNext : rawptr = nil

        when VK_VALIDATION_LAYER {
                enabled_layers := []cstring {
                        "VK_LAYER_KHRONOS_validation",
                        "VK_LAYER_KHRONOS_shader_object",
                }
                
                enabled_extensions := []cstring {
                        vk.KHR_SURFACE_EXTENSION_NAME,
                        // vk.EXT_SHADER_OBJECT_EXTENSION_NAME,
                        vk.EXT_DEBUG_UTILS_EXTENSION_NAME,
                }

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

        } else {
                enabled_layers := []cstring {
                        "VK_LAYER_KHRONOS_shader_object",
                }

                enabled_extensions := []cstring {
                        vk.KHR_SURFACE_EXTENSION_NAME,
                        // vk.EXT_SHADER_OBJECT_EXTENSION_NAME,
                }
        }

        if ok := _vk_prepend_layer_path(); ok == false {
                log.error("Could not prepend the Vulkan Layer environment variable")
        }


        create_info := vk.InstanceCreateInfo {
                sType                   = .INSTANCE_CREATE_INFO,
                pNext                   = pNext,
                pApplicationInfo        = &app_info,
                enabledLayerCount       = len32(enabled_layers),
                ppEnabledLayerNames     = raw_data(enabled_layers),
                enabledExtensionCount   = len32(enabled_extensions),
                ppEnabledExtensionNames = raw_data(enabled_extensions),
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

        d.phys_device = phys_devices[best_index]

        return .Ok
}


_vk_physical_device_score :: proc(d: ^Device, pd: vk.PhysicalDevice, init_info: ^Device_Init_Info) -> int {
        properties: vk.PhysicalDeviceProperties
        d.GetPhysicalDeviceProperties(pd, &properties)

        features: vk.PhysicalDeviceFeatures
        d.GetPhysicalDeviceFeatures(pd, &features)

        score := 0

        // TODO: disqualify GPUs without required_features
        // if .Mesh_Shader in init_info.required_features {}

        if properties.deviceType == .DISCRETE_GPU {
                score += 10_000
        }

        score += int(properties.limits.maxImageDimension2D)

        return score
}


_vk_device_init :: proc(d: ^Device, init_info: ^Device_Init_Info) -> (res: Result) {
        count : u32
        d.GetPhysicalDeviceQueueFamilyProperties(d.phys_device, &count, nil)
        queue_family_props := make([]vk.QueueFamilyProperties, count, context.temp_allocator)
        defer delete(queue_family_props, context.temp_allocator)

        d.GetPhysicalDeviceQueueFamilyProperties(d.phys_device, &count, raw_data(queue_family_props))

        family_graphics : u32
        family_compute  : u32
        has_graphics := false
        has_compute := false
        for props, i in queue_family_props {
                if !has_graphics && .GRAPHICS in props.queueFlags {
                        family_graphics = u32(i)
                        has_graphics = true
                }

                if !has_compute && props.queueFlags == {.COMPUTE} {
                        family_compute = u32(i)
                        has_compute = true
                }
        }

        queue_priorities : f32 = 1.0
        queue_create_infos := make([dynamic]vk.DeviceQueueCreateInfo, context.temp_allocator)
        defer delete(queue_create_infos)

        // Create graphics queue
        graphics_info := vk.DeviceQueueCreateInfo {
                sType            = .DEVICE_QUEUE_CREATE_INFO,
                queueFamilyIndex = family_graphics,
                queueCount       = 1,
                pQueuePriorities = &queue_priorities,
        }

        append(&queue_create_infos, graphics_info)

        // Create async compute queue if available
        if has_compute {
                compute_info := vk.DeviceQueueCreateInfo {
                        sType            = .DEVICE_QUEUE_CREATE_INFO,
                        queueFamilyIndex = family_graphics,
                        queueCount       = 1,
                        pQueuePriorities = &queue_priorities,
                }

                append(&queue_create_infos, compute_info)
        } else {
                d.async_compute_is_shared = true
        }


        device_info := vk.DeviceCreateInfo {
                sType = .DEVICE_CREATE_INFO,
                queueCreateInfoCount = len32(queue_create_infos),
                pQueueCreateInfos = raw_data(queue_create_infos),
                pEnabledFeatures = {},
        }

        vkres := d.CreateDevice(d.phys_device, &device_info, nil, &d.device)
        check_result(vkres) or_return

        vk.load_proc_addresses_device_vtable(d.device, &d.vtable)
        return .Ok
}


_vk_instance_destroy :: proc(d: ^Device) {
        when VK_VALIDATION_LAYER {
                d.DestroyDebugUtilsMessengerEXT(d.instance, d.debug_messenger, nil)
        }
        d.DestroyInstance(d.instance, nil)
}


_vk_device_destroy :: proc(d: ^Device) {
        d.DestroyDevice(d.device, nil)
}


