package callisto_window
import "../platform"

window_ctx: ^Window_Context

Window_Context :: platform.Window_Context

Fullscreen_Mode :: enum {
    Windowed,
    Fullscreen_Windowed,
    Fullscreen,
}

bind_context :: proc(ctx: ^Window_Context) {
    window_ctx = ctx
}

create :: platform.create_window

destroy :: platform.destroy_window

set_size :: proc(width, height: int) {
    platform.set_window_size(window_ctx.handle, width, height)
}

set_fullscreen_mode :: proc(mode: Fullscreen_Mode) {
    platform.set_window_fullscreen_mode(window_ctx.handle, mode)
}

should_close :: proc() -> bool {
    return platform.should_window_close(window_ctx.handle)
}
