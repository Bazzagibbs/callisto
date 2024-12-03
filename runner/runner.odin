package callisto_runner

import cal ".."
import "core:log"
import "core:strings"
import "core:time"
import "core:encoding/ansi"
import "core:fmt"
import "core:os/os2"
import "core:os"
import "core:io"
import "core:bytes"
import "../config"
import "../common"

HOT_RELOAD :: #config(HOT_RELOAD, false)

NO_STDOUT :: ODIN_OS == .Windows && ODIN_WINDOWS_SUBSYSTEM == "windows"


default_runner :: proc (ctx := context) -> cal.Runner {
        runner := cal.Runner {
                ctx                = ctx,
                app_memory         = nil,
                profiler           = {},
                _platform_data     = {},

                // Events/Input
                event_behaviour    = .Before_Loop,
                should_close       = false,
                exit_code          = .Ok,
                scroll_accumulator = 0,
               
                // Application DLL
                symbols            = {},
                last_modified      = 0,
                version            = 0,

                // Executable-owned callbacks
                platform_init      = platform_init,
                platform_destroy   = platform_destroy,
                window_init        = window_init,
                window_destroy     = window_destroy,
                event_pump         = event_pump,
                logger_proc        = logger_multi_proc,
                rhi_logger_proc    = nil, // set below
        }

        when config.RHI == "vulkan" {
                runner.rhi_logger_proc = vk_debug_messenger
        }

        return runner
}


assert_messagebox :: common.assert_messagebox
