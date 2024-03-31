package callisto_window
import "../platform"

Window              :: platform.Window
Fullscreen_Mode     :: platform.Fullscreen_Mode
Cursor_Lock_Mode    :: platform.Cursor_Lock_Mode

create              :: platform.window_create
destroy             :: platform.window_destroy
set_size            :: platform.window_set_size
should_close        :: platform.window_should_close
set_fullscreen      :: platform.window_set_fullscreen
set_cursor_lock     :: platform.cursor_set_lock
set_mouse_input_raw :: platform.mouse_set_raw_input
