package callisto_common

import win "core:sys/windows"


Platform :: struct {
        window_icon : win.HICON,
}

Platform_Window :: struct {
        hwnd : win.HWND,
}
