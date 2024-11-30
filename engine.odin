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

validate_info :: common.validate_info
@(private)
Valid_Not_Nil :: common.Valid_Not_Nil
@(private)
Valid_Range_Int :: common.Valid_Range_Int
@(private)
Valid_Range_Float :: common.Valid_Range_Float


engine_init :: proc(e: ^Engine, init_info: ^Engine_Init_Info, allocator := context.allocator, location := #caller_location) -> (res: Result) {
        validate_info(location,
                Valid_Not_Nil{".runner", init_info.runner},
                // Valid_Not_Nil{".app_memory", init_info.app_memory},
        ) or_return

        e.runner                 = init_info.runner
        e.runner.app_memory      = init_info.app_memory
        e.runner.event_behaviour = init_info.event_behaviour
        e.allocator              = allocator

        e.runner->platform_init(init_info)

        return .Ok
}


engine_destroy :: proc(e: ^Engine) {
        e.runner->platform_destroy()
        e^ = {}

}
