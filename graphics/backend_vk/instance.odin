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
// ==============================


create_instance :: proc(r: ^Renderer_Impl, description: ^common.Engine_Description) -> (res: Result) {
    vk.load_proc_addresses(rawptr(platform.get_vk_proc_address))

    required_exts := make([dynamic]cstring)
    defer delete(required_exts)

    when ODIN_DEBUG {
        if check_validation_layer_support() == false {
            log.error("Validation layers not supported")
            return .Initialization_Failed
        }

        append(&required_exts, "VK_EXT_debug_utils")
    }

    platform_exts := platform.get_vk_required_extensions()
    // defer {
    //     for ext in platform_exts {
    //         delete(ext)
    //     }
    //     delete(platform_exts)
    // }

    for ext in platform_exts {
        append(&required_exts, ext)
    }
    for ext in INSTANCE_EXTS {
        append(&required_exts, ext)
    }

    // APPLICATION INFO ===========================================================

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


    // INSTANCE CREATE ============================================================
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


destroy_instance :: proc(r: ^Renderer_Impl) {
    when ODIN_DEBUG {
        vk.DestroyDebugUtilsMessengerEXT(r.instance, r.debug_messenger, nil)
        log.destroy_console_logger(r.logger)
    }

    vk.DestroyInstance(r.instance, nil)
}


check_validation_layer_support :: proc() -> bool {
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

