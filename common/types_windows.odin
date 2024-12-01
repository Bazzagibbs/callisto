package callisto_common

import win "core:sys/windows"


_Platform_Runner_Data :: struct {
        window_icon : win.HICON,
}

_Platform_Window :: win.HWND
