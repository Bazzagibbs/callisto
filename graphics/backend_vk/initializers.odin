package callisto_graphics_vkb

import vk "vendor:vulkan"
import "core:strings"
import "core:slice"
import "core:log"
import "../../config"
import "../../platform"


create_instance :: proc(cg_ctx: ^Graphics_Context) -> (ok: bool) {
    vk.load_proc_addresses(rawptr(platform.get_vk_proc_address))

    application_info := vk.ApplicationInfo {
        sType               = .APPLICATION_INFO,
        pApplicationName    = strings.unsafe_string_to_cstring(config.APP_NAME),
        applicationVersion  = vk.MAKE_VERSION(config.APP_VERSION.x, config.APP_VERSION.y, config.APP_VERSION.z),
        pEngineName         = strings.unsafe_string_to_cstring(config.ENGINE_NAME),
        engineVersion       = vk.MAKE_VERSION(config.ENGINE_VERSION.x, config.ENGINE_VERSION.y, config.ENGINE_VERSION.z),
        apiVersion          = vk.MAKE_VERSION(1, 3, 0),
    }

    validation_layers :: []cstring {
        "VK_LAYER_KHRONOS_validation",
    }
    enable_validation_layers :: #defined(ODIN_DEBUG)

    required_extensions := make([dynamic]cstring)
    defer delete(required_extensions)
   
    when enable_validation_layers {
        append(&required_extensions, "VK_EXT_debug_utils")
    }

    for ext in platform.get_required_extensions() {
        append(&required_extensions, ext)
    }
    
    // when {.Raytracing} in config.RENDERER_FEATURES {
    //     append(&required_extensions, "VK_KHR_acceleration_structure")
    //     append(&required_extensions, "VK_KHR_ray_tracing_pipeline")
    //     append(&required_extensions, "VK_KHR_ray_query")
    //     append(&required_extensions, "VK_KHR_pipeline_library")
    //     append(&required_extensions, "VK_KHR_deferred_host_operations")
    // }
    
    instance_create_info := vk.InstanceCreateInfo {
        sType                   = .INSTANCE_CREATE_INFO,
        pApplicationInfo        = &application_info,
        enabledLayerCount       = enable_validation_layers ? u32(len(validation_layers)) : 0,
        ppEnabledLayerNames     = raw_data(validation_layers),
        enabledExtensionCount   = u32(len(required_extensions)),
        ppEnabledExtensionNames = raw_data(required_extensions),
    }

    when ODIN_DEBUG {
        cg_ctx.logger = _create_vk_logger()
        debug_create_info := _debug_messenger_create_info(&cg_ctx.logger)

        instance_create_info.pNext = &debug_create_info
    }

    res := vk.CreateInstance(&instance_create_info, nil, &cg_ctx.instance); if res != .SUCCESS {
        log.fatal("Failed to create Vulkan instance:", res)
        return false
    }

    vk.load_proc_addresses(cg_ctx.instance)

    when ODIN_DEBUG {
        res = vk.CreateDebugUtilsMessengerEXT(cg_ctx.instance, &debug_create_info, nil, &cg_ctx.debug_messenger); if res != .SUCCESS {
            log.error("Failed to create Vulkan debug messenger:", res)
        }
    }

    return true
}

destroy_instance :: proc(cg_ctx: ^Graphics_Context) {
    when ODIN_DEBUG {
        vk.DestroyDebugUtilsMessengerEXT(cg_ctx.instance, cg_ctx.debug_messenger, nil)
    }

    vk.DestroyInstance(cg_ctx.instance, nil)
}
