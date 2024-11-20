package callisto

import "base:runtime"
import "core:fmt"
import "core:log"
import "core:strings"
import "core:image"

when ODIN_OS != .Windows {
        #panic("Callisto currently only supports Windows. Other platform layers may be implemented in the future.")
}


Engine :: struct {
        runner    : ^Runner,
        allocator : runtime.Allocator,
}


Engine_Init_Info :: struct {
        runner     : ^Runner,
        app_memory : rawptr,
        icon       : ^image.Image,
}


engine_init :: proc(e: ^Engine, init_info: ^Engine_Init_Info, allocator := context.allocator) -> (res: Result) {
        validate_info(init_info) or_return

        e.runner            = init_info.runner
        e.runner.app_memory = init_info.app_memory
        e.allocator         = allocator

        e.runner->platform_init(init_info)

        return .Ok
}


engine_destroy :: proc(e: ^Engine) {
        e.runner->platform_destroy()
        e^ = {}

}
