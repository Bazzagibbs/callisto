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

HOT_RELOAD :: #config(HOT_RELOAD, false)


NO_STDOUT :: ODIN_OS == .Windows && ODIN_WINDOWS_SUBSYSTEM == "windows"


default_runner :: proc (ctx := context) -> cal.Runner {
        runner := cal.Runner {
                ctx              = ctx,
                should_close     = false,
                platform_init    = platform_init,
                platform_destroy = platform_destroy,
                window_init      = window_init,
                window_destroy   = window_destroy,
                event_pump       = event_pump,
                logger_proc      = logger_multi_proc,
        }

        when config.RHI == "vulkan" {
                runner.rhi_logger_proc = vk_debug_messenger
        }

        return runner
}


