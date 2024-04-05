package callisto_window
import "../platform"
import "../common"

Window              :: common.Window
Fullscreen_Mode     :: common.Display_Fullscreen_Flag
Display_Description :: common.Display_Description
Cursor_Lock_Mode    :: common.Cursor_Lock_Mode

create              :: platform.window_create
destroy             :: platform.window_destroy
set_size            :: platform.window_set_size
should_close        :: platform.window_should_close
present             :: platform.window_present
set_fullscreen      :: platform.window_set_fullscreen
set_cursor_lock     :: platform.cursor_set_lock
set_mouse_input_raw :: platform.mouse_set_raw_input
