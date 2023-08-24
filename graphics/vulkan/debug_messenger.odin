package callisto_graphics_vulkan

import "core:log"
import "core:runtime"
import "core:fmt"
import "core:strings"
import "../../config"
import cal_common "../../common"
import vk "vendor:vulkan"

logger: log.Logger = {}

init_logger :: proc() {
    renderer_logger_opts: log.Options = {
        .Level,
        .Terminal_Color,
    }

    logger = log.create_console_logger(lowest=config.DEBUG_LEVEL, opt=renderer_logger_opts, ident="VK")
}

destroy_logger :: proc(logger: log.Logger) {
    log.destroy_console_logger(logger)
}

// Debug messenger that forwards validation layer messages to the engine's internal logger
debug_messenger_create_info :: proc() -> (messenger_info: vk.DebugUtilsMessengerCreateInfoEXT) {    
    messenger_info = {
        sType = .DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
        messageSeverity = log_level_to_vk_severity(context.logger.lowest_level),
        messageType = {.GENERAL, .VALIDATION, .PERFORMANCE},
        pfnUserCallback = vk.ProcDebugUtilsMessengerCallbackEXT(default_log_callback),
    }
    return
}

default_log_callback :: proc "contextless" (   messageSeverity: vk.DebugUtilsMessageSeverityFlagsEXT,
                                        messageType: vk.DebugUtilsMessageTypeFlagsEXT,
                                        pCallbackData: vk.DebugUtilsMessengerCallbackDataEXT,
                                    ) -> b32 {

    context = runtime.default_context()
    context.logger = logger
    level := vk_severity_to_log_level(messageSeverity)

    message, was_alloc := strings.replace(string(pCallbackData.pMessage), " | ", " \n | ", -1, context.temp_allocator);

    log.log(level, message)
    when config.DEBUG_PANIC_ON_RENDERER_ERROR {
        if level == .Error {
            panic("Renderer error")
        }
    }
    return false
}



log_level_to_vk_severity :: proc(log_level: log.Level) -> (vk_severity: vk.DebugUtilsMessageSeverityFlagsEXT) {
    switch log_level {
        case .Debug:
            vk_severity += {.VERBOSE}
            fallthrough
        case .Info:
            vk_severity += {.INFO}
            fallthrough
        case .Warning:
            vk_severity += {.WARNING}
            fallthrough
        case .Error:
            vk_severity += {.ERROR}
        case .Fatal:
            // Only use fatal in production builds, no validation layer anyway
    }
    return
}

vk_severity_to_log_level :: proc(vk_severity: vk.DebugUtilsMessageSeverityFlagsEXT) -> (log_level: log.Level) {
    if .ERROR in vk_severity {
        return log.Level.Error
    }

    if .WARNING in vk_severity {
        return log.Level.Warning
    }

    if .INFO in vk_severity {
        return log.Level.Info
    }

    return log.Level.Debug
    
}

set_debug_name :: proc(handle: u64, vk_type: vk.ObjectType, name: cstring) {
    when config.DEBUG_ENABLED {
        obj_name_info := vk.DebugUtilsObjectNameInfoEXT {
            sType = .DEBUG_UTILS_OBJECT_NAME_INFO_EXT,
            objectType = vk_type,
            objectHandle = handle,
            pObjectName = name,
        }

        res := vk.SetDebugUtilsObjectNameEXT(bound_state.device, &obj_name_info); if res != .SUCCESS {
            log.error("Failed to set VK object debug name", name, ":", res)
        }
    }
}