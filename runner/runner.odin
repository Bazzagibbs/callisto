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

HOT_RELOAD :: #config(HOT_RELOAD, false)
APP_NAME   :: cal.APP_NAME

NO_LOG_FILE :: #config(NO_LOG_FILE, false)
LOG_FILE_MAX_SIZE := #config(LOG_MAX_FILE_SIZE, 10_000_000) // 10 MB x 2 files
// LOG_FILE_MAX_SIZE := #config(LOG_MAX_FILE_SIZE, 10_000) // 10 KB for testing

NO_STDOUT :: ODIN_OS == .Windows && ODIN_WINDOWS_SUBSYSTEM == "windows"


default_runner :: proc (ctx := context) -> cal.Runner {
        return cal.Runner {
                ctx              = ctx,
                should_close     = false,
                platform_init    = platform_init,
                platform_destroy = platform_destroy,
                window_init      = window_init,
                window_destroy   = window_destroy,
                event_pump       = event_pump,
                logger_proc      = logger_multi_proc,
        }
}


