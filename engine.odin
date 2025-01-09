package callisto

import "base:runtime"
import "core:fmt"
import "core:log"
import "core:strings"
import "core:image"
import "common"

when ODIN_OS != .Windows {
        #panic("Callisto currently only supports Windows. Other platform layers may be implemented in the future.")
}

engine_create :: proc(create_info: ^Engine_Create_Info, allocator := context.allocator, location := #caller_location) -> (e: Engine, res: Result) {
        e.runner                 = create_info.runner
        e.runner.app_memory      = create_info.app_memory
        e.runner.event_behaviour = create_info.event_behaviour
        e.allocator              = allocator

        e.runner->platform_init(create_info)

        return e, .Ok
}


engine_destroy :: proc(e: ^Engine) {
        e.runner->platform_destroy()
}
