package callisto_common

import win "core:sys/windows"
import "../ui/imgui"

_Runner_Data_Impl :: struct {
        window_icon : win.HICON,
}

_Window_Impl :: struct {
        hwnd: win.HWND,
}
