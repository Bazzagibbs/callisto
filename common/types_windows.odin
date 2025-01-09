package callisto_common

import win "core:sys/windows"

_Runner_Data_Impl :: struct {
        window_icon : win.HICON,
}

_Window_Impl :: struct {
        hwnd: win.HWND,
}
