package callisto_gpu

import vk "vendor:vulkan"
import "../config"
import "core:log"

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

        _vk_load_proc_addresses_instance_vtable(d.instance, d.GetInstanceProcAddr, &d.vtable_instance)


        when VK_VALIDATION_LAYER {
                vkres = d.CreateDebugUtilsMessengerEXT(d.instance, &debug_create_info, nil, &d.debug_messenger)
                check_result(vkres) or_return
        }
        
        return .Ok
}


_vk_physical_device_select :: proc(d: ^Device, init_info: ^Device_Init_Info) -> (res: Result) {
        unimplemented()
}


_vk_device_init :: proc(d: ^Device, init_info: ^Device_Init_Info) -> (res: Result) {
        load_proc_addresses_device_vtable(d.device, d.GetDeviceProcAddr, &d.vtable_device)
        unimplemented()
}


_vk_instance_destroy :: proc(d: ^Device) {
        when VK_VALIDATION_LAYER {
                d.DestroyDebugUtilsMessengerEXT(d.instance, d.debug_messenger, nil)
        }
        d.DestroyInstance(d.instance, nil)
}


_vk_device_destroy :: proc(d: ^Device) {

}


