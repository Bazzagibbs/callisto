package callisto

import win "core:sys/windows"
import "core:c"
import "core:log"


Window :: distinct Handle


window_create :: proc(e: ^Engine, create_info: ^Window_Create_Info, out_window: ^Window) -> (res: Result) {
        WIN_CLASS_NAME := win.L("Callisto Window Class")

        dwStyle : win.DWORD

        pos  := [2]c.int{win.CW_USEDEFAULT, win.CW_USEDEFAULT}
        size := [2]c.int{win.CW_USEDEFAULT, win.CW_USEDEFAULT}
        
        pos_temp, pos_exists := create_info.position.?
        if pos_exists {
                pos = {c.int(pos_temp.x), c.int(pos_temp.y)}
        }

        size_temp, size_exists := create_info.size.?
        if size_exists {
                size = {c.int(size_temp.x), c.int(size_temp.y)}
        }

        hWnd := win.CreateWindowExW(
                dwExStyle    = 0,
                lpClassName  = WIN_CLASS_NAME,
                lpWindowName = raw_data(win.utf8_to_utf16(create_info.name)),
                dwStyle      = _window_style_to_win32(create_info.style),
                X            = c.int(pos.x),
                Y            = c.int(pos.y),
                nWidth       = c.int(size.x),
                nHeight      = c.int(size.y),
                hWndParent   = nil, // Maybe add as create_info param?
                hMenu        = nil, // ^^ file, edit, etc.
                hInstance    = _platform_get_hinstance(),
                lpParam      = nil
        )

        if hWnd == nil {
                return .Platform_Error
        }

        out_window^ = Window(hWnd)

        win.ShowWindow(hWnd, win.SW_NORMAL)
        return .Ok
}


poll_input :: proc(window: Window) {
        msg : win.LPMSG
        for win.PeekMessageW(msg, win.HWND(window), 0, 0, win.PM_REMOVE) {
                win.TranslateMessage(msg)
                win.DispatchMessageW(msg)
        }
}


_window_style_to_win32 :: proc(style: Window_Style_Flags) -> win.DWORD {
        dwStyle := win.WS_OVERLAPPED

        if .Border in style {
                dwStyle |= win.WS_BORDER
                dwStyle |= win.WS_CAPTION
        }
        if .Resize_Edges in style {
                dwStyle |= win.WS_SIZEBOX
        }
        if .Menu in style {
                dwStyle |= win.WS_SYSMENU
        }
        if .Minimize_Button in style {
                dwStyle |= win.WS_MINIMIZEBOX
        }
        if .Maximize_Button in style {
                dwStyle |= win.WS_MAXIMIZEBOX
        }

        return dwStyle
}


_platform_get_hinstance :: proc() -> win.HINSTANCE {
        return win.HINSTANCE(win.GetModuleHandleW(nil))
}
