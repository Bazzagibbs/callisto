package callisto_window
import "../platform"

Window_Context      :: platform.Window_Context
Fullscreen_Mode     :: platform.Fullscreen_Mode
Cursor_Lock_Mode    :: platform.Cursor_Lock_Mode

window_ctx: ^Window_Context


bind_context :: proc(ctx: ^Window_Context) {
    window_ctx = ctx
}

init :: platform.init_window

shutdown :: platform.shutdown_window

set_size :: proc(width, height: int) {
    platform.set_window_size(window_ctx, width, height)
}


should_close :: proc() -> bool {
    return platform.should_window_close(window_ctx)
}

set_fullscreen_mode :: proc(mode: Fullscreen_Mode) {
    platform.set_window_fullscreen_mode(window_ctx, mode)
}

set_cursor_lock :: proc(cursor_lock_mode: Cursor_Lock_Mode) {
    platform.set_cursor_lock(window_ctx, cursor_lock_mode)
}

set_mouse_input_raw :: proc(raw_input: bool) {
    platform.set_mouse_input_raw(window_ctx, raw_input)
}
