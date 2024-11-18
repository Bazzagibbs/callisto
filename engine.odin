package callisto

import "base:runtime"
import "core:fmt"
import "core:log"
import "core:strings"
import "core:image"

Engine :: struct {
        runner   : ^Runner,
        allocator : runtime.Allocator,
        app_name : string,
}


Engine_Init_Info :: struct {
        runner        : ^Runner,
        app_name      : string,
        window_icon   : ^image.Image,
}

engine_init :: proc(e: ^Engine, init_info: ^Engine_Init_Info, allocator := context.allocator) -> (res: Result) {
        validate_info(init_info) or_return

        e.runner = init_info.runner
        e.allocator = allocator

        e.app_name = strings.clone(init_info.app_name, e.allocator)
        e.runner->platform_init(init_info)

        return .Ok
}

engine_destroy :: proc(e: ^Engine) {
        delete(e.app_name, e.allocator)
        e.runner->platform_destroy()
        e^ = {}

}
