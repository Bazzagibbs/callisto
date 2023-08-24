package callisto_window

import "../debug"

Window_Handle :: #type rawptr

handle: Window_Handle = {}

init :: proc() -> (ok: bool) {
    debug.profile_scope()
    return _init()
}

shutdown :: proc() {
    debug.profile_scope()
    _shutdown()
}

should_close :: proc() -> bool {
    return _should_close()
}

poll_events :: proc() {
    debug.profile_scope()
    _poll_events()
}

set_window_size :: proc(width, height: int) {
    _set_window_size(width, height)
}

get_required_vk_extensions :: proc() -> []cstring {
    return _get_required_vk_extensions()
}