package callisto_engine_renderer

import "core:log"


init :: proc () -> (ok: bool) {
    return _init()
}


shutdown :: proc() {
    _shutdown()
}

cmd_draw_frame :: proc() {
    _cmd_draw_frame()
}