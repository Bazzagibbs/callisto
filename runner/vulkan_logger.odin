package callisto_runner

import vk "vendor:vulkan"
import cal ".."
import "../config"
import "core:log"

when config.RHI == "vulkan" {

        vk_debug_messenger :: proc "system" (message_severity: vk.DebugUtilsMessageSeverityFlagsEXT, message_types: vk.DebugUtilsMessageTypeFlagsEXT, callback_data: ^vk.DebugUtilsMessengerCallbackDataEXT, user_data: rawptr) -> b32 {
                runner : ^cal.Runner = (^cal.Runner)(user_data)
                context = runner.ctx

                log.log(vk_to_logger_level(message_severity), message_types, callback_data.pMessage)

                return false
        }

        vk_to_logger_level :: proc "contextless" (vk_severity: vk.DebugUtilsMessageSeverityFlagsEXT) -> log.Level {
                if .ERROR in vk_severity {
                        return .Error
                }

                if .WARNING in vk_severity {
                        return .Warning
                }

                if .VERBOSE in vk_severity {
                        return .Debug
                }

                return .Info
        }
}
