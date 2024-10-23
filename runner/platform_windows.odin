package callisto_runner

import win "core:sys/windows"
import "core:log"
import "core:fmt"

Platform :: struct {
        hInstance: win.HINSTANCE,
        windowClassName: win.LPCWSTR,
}


_window_proc :: proc "stdcall" (hWnd: win.HWND, uMsg: win.UINT, wParam: win.WPARAM, lParam: win.LPARAM) -> win.LRESULT  {
        context = _platform_callback_context
        return win.DefWindowProcW(hWnd, uMsg, wParam, lParam)
}

_platform_init :: proc(p: ^Platform) -> (res: Result) {
        WIN_CLASS_NAME := win.L("Callisto Window Class")

        log.info("Platform init")

        p.hInstance = win.HINSTANCE(win.GetModuleHandleW(nil))
        p.windowClassName = WIN_CLASS_NAME

        wndClass := win.WNDCLASSW {
                lpfnWndProc = _window_proc,
                hInstance = p.hInstance,
                lpszClassName = p.windowClassName,
        }

        win.RegisterClassW(&wndClass)

        return .Ok
}


