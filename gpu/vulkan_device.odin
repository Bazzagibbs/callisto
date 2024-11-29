package callisto_gpu

import vk "vendor:vulkan"
import "../config"
import "core:log"

// when RHI == "vulkan"

VK_VALIDATION_LAYER :: ODIN_DEBUG


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

        when VK_VALIDATION_LAYER {
                enabled_layers := []cstring {
                        "VK_LAYER_KHRONOS_validation",
                        "VK_LAYER_KHRONOS_shader_object",
                }
        } else {
                enabled_layers := []cstring {
                        "VK_LAYER_KHRONOS_shader_object",
                }
        }

        if ok := _vk_prepend_layer_path(); ok == false {
                log.error("Could not prepend the Vulkan Layer environment variable")
        }

        create_info := vk.InstanceCreateInfo {
                sType = .INSTANCE_CREATE_INFO,
                pApplicationInfo = &app_info,
                enabledLayerCount = len32(enabled_layers),
                ppEnabledLayerNames = raw_data(enabled_layers),
        }

        vkres := vk.CreateInstance(&create_info, nil, &d.instance)
        check_result(vkres) or_return

        _vk_load_proc_addresses_instance_vtable(d.instance, &d.vtable_instance)
        return .Ok
}


_vk_physical_device_select :: proc(d: ^Device, init_info: ^Device_Init_Info) -> (res: Result) {
        unimplemented()
}


_vk_device_init :: proc(d: ^Device, init_info: ^Device_Init_Info) -> (res: Result) {
        vk.load_proc_addresses_device_vtable(d.device, &d.vtable_device)
        unimplemented()
}


_vk_instance_destroy :: proc(d: ^Device) {
}

_vk_device_destroy :: proc(d: ^Device) {

}


