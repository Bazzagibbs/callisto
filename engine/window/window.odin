package callisto_window

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