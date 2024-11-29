package callisto_runner

import vk "../vendor_mod/vulkan"
import cal ".."
import "../config"
import "core:log"

when config.RHI == "vulkan" {

        vk_debug_messenger :: proc "system" (message_severity: vk.DebugUtilsMessageSeverityFlagsEXT, message_types: vk.DebugUtilsMessageTypeFlagsEXT, callback_data: ^vk.DebugUtilsMessengerCallbackDataEXT, user_data: rawptr) -> b32 {
                runner : ^cal.Runner = (^cal.Runner)(user_data)
                context = runner.ctx

                log.log(vk_to_logger_level(message_severity), vk_fix_message_types(message_types), callback_data.pMessage)

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

        vk_fix_message_types :: proc "contextless" (message_types: vk.DebugUtilsMessageTypeFlagsEXT) -> string {
                if .PERFORMANCE in message_types {
                        return "[PERFORMANCE]"
                }
                if .DEVICE_ADDRESS_BINDING in message_types {
                        return "[BINDING]"
                }
                if .VALIDATION in message_types {
                        return "[VALIDATION]"
                }
                if .GENERAL in message_types {
                        return "[GENERAL]"
                }

                return ""
        }
}
