package callisto_window

Window_Handle :: #type rawptr

handle: Window_Handle = {}

init :: proc() -> (ok: bool) {
    return _init()
}

shutdown :: proc() {
    _shutdown()
}

should_close :: proc() -> bool {
    return _should_close()
}

poll_events :: proc() {
    _poll_events()
}

set_window_size :: proc(width, height: int) {
    _set_window_size(width, height)
}

get_required_vk_extensions :: proc() -> []cstring {
    return _get_required_vk_extensions()
}