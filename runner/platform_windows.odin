package callisto_runner

import "base:intrinsics"
import "base:runtime"
import win "core:sys/windows"
import "core:log"
import "core:fmt"
import "core:os"
import "core:c"

import cal ".."


WIN_CLASS_NAME :: "Callisto Window Class"

_window_proc :: proc "stdcall" (hWnd: win.HWND, uMsg: win.UINT, wParam: win.WPARAM, lParam: win.LPARAM) -> (result: win.LRESULT)  {
        result = 0

        if uMsg == win.WM_CREATE {
                createstruct := transmute(^win.CREATESTRUCTW)(lParam)
                runner := (^Runner)(createstruct.lpCreateParams)
                win.SetWindowLongPtrW(hWnd, win.GWLP_USERDATA, transmute(int)(runner))
                return 0
        }

        switch uMsg {
        case win.WM_SIZE:
                resized_type: Window_Resized_Type
                switch wParam {
                case win.SIZE_MAXIMIZED:
                        resized_type = .Maximized
                case win.SIZE_MINIMIZED:
                        resized_type = .Minimized
                case win.SIZE_MAXHIDE:
                        resized_type = .Occluded
                case win.SIZE_MAXSHOW:
                        resized_type = .Revealed
                case win.SIZE_RESTORED:
                        resized_type = .Restored
                }

                event := Window_Event {
                        window       = {{hwnd = hWnd}},
                        type         = .Resized,
                        resized_type = resized_type,
                        size         = ([2]i32)(lParam),
                }
                if _dispatch_callisto_event(event, hWnd, lParam) {
                        return 1
                }

        case win.WM_SIZING:
                size_rect := (^win.RECT)(uintptr(lParam))
                size := [2]i32 {
                        size_rect.right - size_rect.left,
                        size_rect.bottom - size_rect.top,
                }

                event := Window_Event {
                        window       = {{hwnd = hWnd}},
                        type         = .Resized,
                        resized_type = .In_Progress,
                        size         = size,
                }
                if _dispatch_callisto_event(event, hWnd, lParam) {
                        return 1
                }


        case win.WM_MOVE:
                // event = Window_Event {
                //         window = {{hwnd = hWnd}},
                //         type = .Moved,
                //         
                // }

        case win.WM_KEYDOWN:
                // event = Input_Event {
                //         window = {{hwnd = hWnd}},
                //         device_id = 0, // TODO
                //         source = cal._input_source_translate_windows(lParam),
                //         motion = .Button_Down,
                // }
        case win.WM_KEYUP:
        case win.WM_POINTERDOWN:
        case win.WM_POINTERUP:
        case win.WM_POINTERWHEEL:
        case win.WM_POINTERHWHEEL:
        case win.WM_POINTERUPDATE:
        case win.WM_QUIT:
        }

        return win.DefWindowProcW(hWnd, uMsg, wParam, lParam)
}


@(private)
_dispatch_callisto_event :: #force_inline proc "contextless" (event: Event, hwnd: win.HWND, lparam: win.LPARAM) -> (handled: bool) {
        runner := transmute(^Runner)win.GetWindowLongPtrW(hwnd, win.GWLP_USERDATA)
        if runner == nil {
                return false
        }

        context = runner.ctx
        return runner.symbols.callisto_event(event, runner.app_memory)
}

platform_init :: proc (runner: ^Runner, init_info: ^Engine_Init_Info) -> (res: Result) {
        hIcon : win.HICON

        if init_info.icon != nil {
                // TODO: custom icon creation here
                hIcon = win.LoadIconW(nil, transmute(win.wstring)(win.IDI_APPLICATION))
        } else {
                hIcon = win.LoadIconW(nil, transmute(win.wstring)(win.IDI_APPLICATION))
        }

        wndClass := win.WNDCLASSEXW {
                cbSize        = size_of(win.WNDCLASSEXW),
                style         = win.CS_HREDRAW | win.CS_VREDRAW,
                lpfnWndProc   = _window_proc,
                hInstance     = win.HINSTANCE(win.GetModuleHandleW(nil)),
                hIcon         = hIcon,
                hCursor       = nil, // might want to change cursor dynamically
                lpszClassName = win.L(WIN_CLASS_NAME),
                hIconSm       = win.LoadIconW(nil, transmute(win.wstring)(win.IDI_APPLICATION)),
        }

        atom := win.RegisterClassExW(&wndClass)
        if atom == 0 {
                log.error("platform_init failed")
                return .Platform_Error
        }

        return .Ok
}


platform_destroy :: proc (runner: ^Runner) {
        // if using custom icon, destroy it now
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

        style := _window_style_to_win32(create_info.style)
        test_style := win.WS_OVERLAPPEDWINDOW | win.WS_VISIBLE

        out_window._platform.hwnd = win.CreateWindowExW(
                dwExStyle    = win.WS_EX_OVERLAPPEDWINDOW,
                lpClassName  = win.L(WIN_CLASS_NAME),
                lpWindowName = raw_data(win.utf8_to_utf16(create_info.name)),
                dwStyle      = style,
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
                log.error("window_create failed")
                return .Platform_Error
        }

        return .Ok
        
}


window_destroy :: proc (runner: ^Runner, window: ^Window) {
        win.DestroyWindow(window._platform.hwnd)
}


_window_style_to_win32 :: proc(style: Window_Style_Flags) -> win.DWORD {
        dwStyle := win.WS_OVERLAPPED | win.WS_VISIBLE

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
                        message := fmt.tprint(..message_args)
                        win.MessageBoxW(nil, win.utf8_to_wstring(message), win.L("Fatal Error"), win.MB_OK)
                        fmt.eprintfln("%v: %v", loc, message)
                        intrinsics.debug_trap()
                        os.exit(int(win.GetLastError()))
                }
        }
}
