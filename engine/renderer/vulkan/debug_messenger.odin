package callisto_engine_renderer_vulkan

import "core:log"
import vk "vendor:vulkan"

_logger: log.Logger = {}

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

default_log_callback :: proc(   messageSeverity: vk.DebugUtilsMessageSeverityFlagsEXT,
                                messageType: vk.DebugUtilsMessageTypeFlagsEXT,
                                pCallbackData: vk.DebugUtilsMessengerCallbackDataEXT,
                                pUserData: rawptr,
                            ) -> b32 {
    context.logger = _logger
    level := vk_severity_to_log_level(messageSeverity)
    log.log(level, pCallbackData.pMessage)
    return false
}

create_debug_messenger :: proc(instance: vk.Instance, create_info: ^vk.DebugUtilsMessengerCreateInfoEXT) -> (debug_messenger: vk.DebugUtilsMessengerEXT, ok: bool) {
    _logger = context.logger // Store engine logger for the callback, as it won't be provided in the callback's context
    create_impl :=  vk.ProcCreateDebugUtilsMessengerEXT(vk.GetInstanceProcAddr(instance, "vkCreateDebugUtilsMessengerEXT"))
    if create_impl == nil do return {}, false

    ok = create_impl(instance, create_info, nil, &debug_messenger) == .SUCCESS
    return
}

destroy_debug_messenger :: proc(messenger: vk.DebugUtilsMessengerEXT) {

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