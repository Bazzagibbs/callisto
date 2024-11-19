package callisto_runner

import "base:intrinsics"
import win "core:sys/windows"
import "core:log"
import "core:fmt"
import "core:os"
import "core:c"


WIN_CLASS_NAME :: "Callisto Window Class"

_window_proc :: proc "stdcall" (hWnd: win.HWND, uMsg: win.UINT, wParam: win.WPARAM, lParam: win.LPARAM) -> (result: win.LRESULT)  {
        result = 0

        if uMsg == win.WM_CREATE {
                createstruct := transmute(^win.CREATESTRUCTW)(lParam)
                runner := (^Runner)(createstruct.lpCreateParams)
                win.SetWindowLongPtrW(hWnd, win.GWLP_USERDATA, transmute(int)(runner))
                return
        }

        runner := transmute(^Runner)win.GetWindowLongPtrW(hWnd, win.GWLP_USERDATA)
        context = runner.ctx

        event: Event

        switch uMsg {
        case win.WM_SIZE:
        case win.WM_KEYDOWN:
        case win.WM_KEYUP:
        case win.WM_POINTERDOWN:
        case win.WM_POINTERUP:
        case win.WM_POINTERWHEEL:
        case win.WM_POINTERHWHEEL:
        case win.WM_POINTERUPDATE:
        }

        // translate win32 events to callisto event
        runner.symbols.callisto_event(event, runner.app_data)
        
        
        return win.DefWindowProcW(hWnd, uMsg, wParam, lParam)
}


platform_init :: proc (runner: ^Runner, init_info: ^Engine_Init_Info) -> (res: Result) {
        // Maybe get icon from init_info

        wndClass := win.WNDCLASSEXW {
                cbSize        = size_of(win.WNDCLASSEXW),
                style         = win.CS_HREDRAW | win.CS_VREDRAW,
                lpfnWndProc   = _window_proc,
                hInstance     = win.HINSTANCE(win.GetModuleHandleW),
                hIcon         = win.LoadIconW(nil, transmute(win.wstring)(win.IDI_APPLICATION)),
                // hCursor       = win.LoadCursorW(nil, transmute(win.wstring)(win.IDC_ARROW)), // might want to change cursor dynamically
                lpszClassName = win.L(WIN_CLASS_NAME),
                hIconSm       = win.LoadIconW(nil, transmute(win.wstring)(win.IDI_APPLICATION)),
        }

        win.RegisterClassExW(&wndClass)

        return .Ok
}

platform_destroy :: proc (runner: ^Runner) {
        
}


window_create :: proc (runner: ^Runner, create_info: ^Window_Create_Info, out_window: ^Window) -> (res: Result) {
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

        out_window._platform.hwnd = win.CreateWindowExW(
                dwExStyle    = 0,
                lpClassName  = win.L(WIN_CLASS_NAME),
                lpWindowName = raw_data(win.utf8_to_utf16(create_info.name)),
                dwStyle      = _window_style_to_win32(create_info.style),
                X            = pos.x,
                Y            = pos.y,
                nWidth       = size.x,
                nHeight      = size.y,
                hWndParent   = nil, // Maybe add as create_info param?
                hMenu        = nil, // ^^ file, edit, etc.
                hInstance    = win.HINSTANCE(win.GetModuleHandleW(nil)),
                lpParam      = runner
        )

        if out_window._platform.hwnd == nil {
                return .Platform_Error
        }

        return .Ok
        
}


window_destroy :: proc (runner: ^Runner, window: ^Window) {
        win.DestroyWindow(window._platform.hwnd)
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


assert_messagebox :: proc(assertion: bool, message_args: ..any, loc := #caller_location) {
        when !ODIN_DISABLE_ASSERT {
                if !assertion {
                        message := fmt.tprint(message_args)
                        win.MessageBoxW(nil, win.utf8_to_wstring(message), win.L("Fatal Error"), win.MB_OK)
                        fmt.eprintfln("%v: %v", loc, message)
                        intrinsics.debug_trap()
                        os.exit(int(win.GetLastError()))
                }
        }
}
