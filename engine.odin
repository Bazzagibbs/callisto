package callisto

import "runner"
import "core:fmt"

Engine :: struct {
        initialized: bool,
}

// Pass the main loop control to the Runner.
// Note: Only call this in standalone (non-dll) builds!
run_main :: proc "contextless" (callbacks: Callbacks) {
        when ODIN_BUILD_MODE == .Dynamic {
                #panic("ERROR: run_main called in a DLL build!")
        }

        runner.main_static(callbacks)
}


init :: proc(e: ^Engine) -> (res: Result) {
        if e.initialized {
                return .Ok
        }

        return .Ok
}

destroy :: proc(e: ^Engine) {

}
