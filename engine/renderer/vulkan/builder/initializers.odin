package callisto_engine_renderer_vulkan

import vk "vendor:vulkan"
import "core:log"
import "../../../../config"


application_info :: proc() -> (vk.ApplicationInfo) {    
    app_info: vk.ApplicationInfo = {
        sType = .APPLICATION_INFO,
        pApplicationName = cstring(config.App_Name),
        applicationVersion = vk.MAKE_VERSION(config.App_Version[0], config.App_Version[1], config.App_Version[2]),
        pEngineName = "Callisto",
        engineVersion = vk.MAKE_VERSION(config.Engine_Version[0], config.Engine_Version[1], config.Engine_Version[2]),
        apiVersion = vk.MAKE_VERSION(1, 1, 0),
    }
    return app_info
}

// Default information for the Vulkan instance.
instance_create_info :: proc() -> (vk.InstanceCreateInfo) {
    instance_info: vk.InstanceCreateInfo = {
        sType = .INSTANCE_CREATE_INFO,
    }
    
    return instance_info
}


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