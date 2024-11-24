package callisto_runner

import "base:intrinsics"
import "base:runtime"
import win "core:sys/windows"
import "core:log"
import "core:fmt"
import "core:os"
import "core:c"
import "core:unicode/utf8"
import "core:math"

import cal ".."


WIN_CLASS_NAME :: "Callisto Window Class"
MAX_EVENTS_PER_FRAME :: 128

@(private="file")
_window_proc :: proc "stdcall" (hwnd: win.HWND, uMsg: win.UINT, wparam: win.WPARAM, lparam: win.LPARAM) -> (result: win.LRESULT)  {
        result = 0

        switch uMsg {
        case win.WM_CREATE:
                createstruct := transmute(^win.CREATESTRUCTW)(lparam)
                runner := (^Runner)(createstruct.lpCreateParams)
                win.SetWindowLongPtrW(hwnd, win.GWLP_USERDATA, transmute(int)(runner))

                context = runner.ctx

                window_rect : win.RECT
                win.GetWindowRect(hwnd, &window_rect)

                dpi := win.GetDpiForWindow(hwnd)
                dpi_scale := f32(dpi) / 96.0
                pixel_size := [2]i32 {
                        window_rect.right - window_rect.left, 
                        window_rect.bottom - window_rect.top
                }

                event := Window_Event {
                        window = {{hwnd}},
                        event = Window_Opened {
                                position = {window_rect.left, window_rect.top},
                                pixel_size  = pixel_size,
                                scaled_size = {i32(f32(pixel_size.x) / dpi_scale), i32(f32(pixel_size.y) / dpi_scale)},
                                dpi_scale   = dpi_scale,
                        },
                }

                _dispatch_callisto_event(hwnd, event)
                return 0

        case win.WM_SIZE, win.WM_DPICHANGED:
                dpi         := win.GetDpiForWindow(hwnd)
                dpi_scale   := f32(dpi) / 96.0
                pixel_size  := [2]i32{ 
                        i32(win.LOWORD(lparam)), 
                        i32(win.HIWORD(lparam))
                }

                window_event := Window_Resized {
                        pixel_size  = pixel_size,
                        scaled_size = {i32(f32(pixel_size.x) / dpi_scale), i32(f32(pixel_size.y) / dpi_scale)},
                        dpi_scale   = dpi_scale,
                }

                if uMsg == win.WM_DPICHANGED {
                        window_event.type = .Dpi_Changed
                } else {
                        switch wparam {
                        case win.SIZE_MAXIMIZED:  window_event.type = .Maximized
                        case win.SIZE_MINIMIZED:  window_event.type = .Minimized
                        case win.SIZE_MAXHIDE:    window_event.type = .Occluded
                        case win.SIZE_MAXSHOW:    window_event.type = .Revealed
                        case win.SIZE_RESTORED:   window_event.type = .Restored
                        }
                }
                event := Window_Event {
                        window = {{hwnd = hwnd}},
                        event  = window_event,
                }

                if _dispatch_callisto_event(hwnd, event) {
                        return 0
                }

        case win.WM_MOVE:
                event := Window_Event {
                        window = {{hwnd = hwnd}},
                        event = Window_Moved {
                                position = {i32(win.LOWORD(lparam)), i32(win.HIWORD(lparam))}
                        }
                }
                
                if _dispatch_callisto_event(hwnd, event) {
                        return 0
                }

        // case win.WM_KEYDOWN, win.WM_SYSKEYDOWN:
        //         source, hand := _input_button_source_translate(wparam)
        //         flags := Keystroke_Flags(lparam)
        //
        //         if flags.extended_key {
        //                 hand = .Right
        //         }
        //
        //         input := Input_Button {
        //                 source    = source,
        //                 hand      = hand,
        //                 modifiers = _input_button_get_modifiers(),
        //                 motion    = .Down if !flags.previous_down else .Held,
        //         }
        //
        //         event := Input_Event {
        //                 window    = {{hwnd = hwnd}},
        //                 device_id = 0, // TODO
        //                 event = input
        //         }
        //
        //         any_handled := false
        //         any_handled |= _dispatch_callisto_event(hwnd, event)
        //
        //         if flags.repeat > 1 {
        //                 input.motion = .Held
        //                 event.event  = input
        //                 for i in 1..<flags.repeat {
        //                         any_handled |= _dispatch_callisto_event(hwnd, event)
        //                 }
        //         }
        //         
        //         if any_handled {
        //                 return 0
        //         }
        //
        // case win.WM_KEYUP, win.WM_SYSKEYUP:
        //         source, hand := _input_button_source_translate(wparam)
        //         flags := Keystroke_Flags(lparam)
        //
        //         if flags.extended_key {
        //                 hand = .Right
        //         }
        //
        //         input := Input_Button {
        //                 source    = source,
        //                 hand      = hand,
        //                 modifiers = _input_button_get_modifiers(),
        //                 motion = .Up
        //         }
        //
        //         event := Input_Event {
        //                 window    = {{hwnd = hwnd}},
        //                 device_id = 0, // TODO
        //                 event = input
        //         }
        //
        //         if _dispatch_callisto_event(hwnd, event) {
        //                 return 0
        //         }

        case win.WM_CHAR:
                utf16_character := win.WCHAR(wparam)
                utf8_character: [4]win.CHAR
                utf8_length := win.WideCharToMultiByte(
                        win.CP_UTF8, 0, 
                        &utf16_character, 1, &utf8_character[0], i32(len(utf8_character)), nil, nil)

                text, _ := utf8.decode_rune_in_bytes(utf8_character[:utf8_length])

                event := Input_Event {
                        window = {{hwnd}},
                        event = Input_Text {
                                text = text,
                                modifiers = _get_input_modifiers(),
                        }
                }
                
                if _dispatch_callisto_event(hwnd, event) {
                        return 0
                }

        case win.WM_MOUSEMOVE:
                mouse_pos := [2]i32{
                        i32(win.LOWORD(lparam)), 
                        i32(win.HIWORD(lparam))
                }

                event := Input_Event {
                        window = {{hwnd}},
                        device_id = 0,
                        event = Input_Vector2 {
                                source = .Mouse_Position_Cursor,
                                modifiers = _get_input_modifiers(),
                                value = {f32(mouse_pos.x), f32(mouse_pos.y)},
                        },
                }

                if _dispatch_callisto_event(hwnd, event) {
                        return 0
                }

        case win.WM_INPUT:
                runner := _wndproc_runner_from_user_data(hwnd)
                context = runner.ctx

                dwSize: win.UINT = size_of(win.RAWINPUT)
                lpb: [size_of(win.RAWINPUT)]byte
                size := win.GetRawInputData(win.HRAWINPUT(lparam), win.RID_INPUT, &lpb[0], &dwSize, size_of(win.RAWINPUTHEADER))

                raw := transmute(win.RAWINPUT)lpb
                raw_type := RawInput_Type(raw.header.dwType)

                switch raw_type {
                case .Mouse: _dispatch_raw_mouse(hwnd, win.RAWMOUSE(raw.data.mouse))
                case .Keyboard:
                case .Hid:
                }



        case win.WM_CLOSE:
                event := Window_Event {
                        window = {{hwnd}},
                        event  = Window_Close_Request{},
                }

                if _dispatch_callisto_event(hwnd, event) {
                        return 1
                }


        case win.WM_DESTROY: 
                event := Window_Event {
                        window = {{hwnd}},
                        event = Window_Closed{},
                }

                if _dispatch_callisto_event(hwnd, event) {
                        return 1
                }

                
                runner := _wndproc_runner_from_user_data(hwnd)
                context = runner.ctx

                // Quit app if not handled
                win.PostQuitMessage(0)
                
        }

        return win.DefWindowProcW(hwnd, uMsg, wparam, lparam)
}

@(private="file")
_wndproc_runner_from_user_data :: #force_inline proc "contextless" (hwnd: win.HWND) -> ^Runner {
        return transmute(^Runner)win.GetWindowLongPtrW(hwnd, win.GWLP_USERDATA)
}

@(private="file")
_dispatch_callisto_event :: #force_inline proc "contextless" (hwnd: win.HWND, event: Event) -> (handled: bool) {
        runner := _wndproc_runner_from_user_data(hwnd)
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
                hCursor       = win.LoadCursorW(nil, transmute(win.wstring)(win.IDC_ARROW)),
                // hCursor       = nil, // might want to change cursor dynamically
                lpszClassName = win.L(WIN_CLASS_NAME),
                hIconSm       = win.LoadIconW(nil, transmute(win.wstring)(win.IDI_APPLICATION)),
        }

        atom := win.RegisterClassExW(&wndClass)
        if atom == 0 {
                log.error("RegisterClass failed")
                return .Platform_Error
        }
        
        rids := []win.RAWINPUTDEVICE {
                { // keyboard
                        usUsagePage = win.HID_USAGE_PAGE_GENERIC,
                        usUsage     = win.HID_USAGE_GENERIC_KEYBOARD,
                        dwFlags     = 0,
                        hwndTarget  = nil,
                },
                { // mouse
                        usUsagePage = win.HID_USAGE_PAGE_GENERIC,
                        usUsage     = win.HID_USAGE_GENERIC_MOUSE,
                        dwFlags     = 0,
                        hwndTarget  = nil,
                },
                { // gamepad
                        usUsagePage = win.HID_USAGE_PAGE_GENERIC,
                        usUsage     = win.HID_USAGE_GENERIC_GAMEPAD,
                        dwFlags     = 0,
                        hwndTarget  = nil,
                },
        }

        ok := win.RegisterRawInputDevices(raw_data(rids), u32(len(rids)), size_of(win.RAWINPUTDEVICE))
        if !ok {
                log.error("RegisterRawInputDevices failed")
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

        win.SetProcessDpiAwarenessContext(win.DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE)

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


event_pump :: proc (runner: ^Runner) {
        msg: win.MSG
        for win.PeekMessageW(&msg, nil, 0, 0, win.PM_REMOVE) {
                if msg.message == win.WM_QUIT {
                        runner.should_close = true
                        runner.exit_code = Exit_Code(msg.wParam)
                }

                win.TranslateMessage(&msg)
                win.DispatchMessageW(&msg)
        }
}


event_wait :: proc (runner: ^Runner) {
        msg: win.MSG
        // Blocks until there's a message in the queue
        if win.GetMessageW(&msg, nil, 0, 0) == 0 {
                runner.should_close = true
                runner.exit_code = Exit_Code(msg.wParam)
        }

        win.TranslateMessage(&msg)
        win.DispatchMessageW(&msg)
}

@(private="file")
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

@(private="file")
_get_input_modifiers :: proc "contextless" () -> Input_Modifiers {
        mods := Input_Modifiers {}
        if Key_State(win.GetKeyState(win.VK_SHIFT)).is_pressed {
                mods += {.Shift}
        }
        if Key_State(win.GetKeyState(win.VK_CONTROL)).is_pressed {
                mods += {.Ctrl}
        }
        if Key_State(win.GetKeyState(win.VK_MENU)).is_pressed {
                mods += {.Alt}
        }
        if Key_State(win.GetKeyState(win.VK_LWIN)).is_pressed ||       
                Key_State(win.GetKeyState(win.VK_RWIN)).is_pressed {
                mods += {.Super}
        }

        return mods
}

@(private="file")
_input_button_source_translate :: proc "contextless" (key_code: win.WPARAM) -> (src: Input_Button_Source, hand: Input_Hand) {
        src  = .Unknown
        hand = .Left

        switch key_code {
        case win.VK_LBUTTON    : src = .Mouse_Left
        case win.VK_RBUTTON    : src = .Mouse_Right
        case win.VK_MBUTTON    : src = .Mouse_Middle
        case win.VK_XBUTTON1   : src = .Mouse_3
        case win.VK_XBUTTON2   : src = .Mouse_4

        case win.VK_BACK       : src = .Backspace
        case win.VK_TAB        : src = .Tab
        case win.VK_RETURN     : src = .Enter
        case win.VK_SHIFT      : src = .Shift
        case    win.VK_CONTROL, 
                win.VK_LCONTROL: src = .Ctrl 
        case    win.VK_RCONTROL:  { src  = .Ctrl; hand = .Right }
        case    win.VK_MENU, 
                win.VK_LMENU   : src = .Alt
        case    win.VK_RMENU   : { src  = .Alt; hand = .Right }
        case win.VK_CAPITAL    : src = .Caps_Lock
        case win.VK_ESCAPE     : src = .Esc

        case win.VK_SPACE      : src = .Space
        case win.VK_PRIOR      : src = .Page_Up
        case win.VK_NEXT       : src = .Page_Down
        case win.VK_END        : src = .End
        case win.VK_HOME       : src = .Home
        case win.VK_LEFT       : src = .Left
        case win.VK_UP         : src = .Up
        case win.VK_RIGHT      : src = .Right
        case win.VK_DOWN       : src = .Down
        case win.VK_SNAPSHOT   : src = .Print_Screen
        case win.VK_INSERT     : src = .Insert
        case win.VK_DELETE     : src = .Delete
        // numbers, letters
        case    0x30..=0x39,
                0x41..=0x5a    : src = Input_Button_Source(key_code)
        case    win.VK_LWIN,
                win.VK_RWIN    : src = .Super
        // numpad, function keys
        case    0x60..=0x69,
                0x70..=0x87    : src = Input_Button_Source(key_code)

        case win.VK_NUMLOCK    : src = .Num_Lock
        case win.VK_SCROLL     : src = .Scroll_Lock
        case win.VK_OEM_1      : src = .Semicolon
        case win.VK_OEM_PLUS   : src = .Plus
        case win.VK_OEM_COMMA  : src = .Comma
        case win.VK_OEM_MINUS  : src = .Minus
        case win.VK_OEM_PERIOD : src = .Period
        case win.VK_OEM_2      : src = .Forward_Slash
        case win.VK_OEM_3      : src = .Backtick
        case win.VK_OEM_4      : src = .Bracket_Open
        case win.VK_OEM_5      : src = .Backward_Slash
        case win.VK_OEM_6      : src = .Bracket_Close
        case win.VK_OEM_7      : src = .Quote
        case win.VK_OEM_8      : src = .Unknown
        case win.VK_DECIMAL    : src = .Period
        }

        return
}

_input_button_mouse_translate :: proc "contextless" (flag: RawInput_Mouse_Button_Flag, data: win.USHORT, mods: Input_Modifiers) -> (union {
        Input_Text, Input_Button, Input_Vector1, Input_Vector2, Input_Vector3})  {
        #partial switch flag {
        case .Left_Down       : return Input_Button {.Mouse_Left, .Left, mods, .Down}
        case .Left_Up         : return Input_Button {.Mouse_Left, .Left, mods, .Up}
        case .Right_Down      : return Input_Button {.Mouse_Right, .Left, mods, .Down}
        case .Right_Up        : return Input_Button {.Mouse_Right, .Left, mods, .Up}
        case .Middle_Down     : return Input_Button {.Mouse_Middle, .Left, mods, .Down}
        case .Middle_Up       : return Input_Button {.Mouse_Middle, .Left, mods, .Up}
        case .Button_4_Down   : return Input_Button {.Mouse_4, .Left, mods, .Down}
        case .Button_4_Up     : return Input_Button {.Mouse_4, .Left, mods, .Up}
        case .Button_5_Down   : return Input_Button {.Mouse_5, .Left, mods, .Down}
        case .Button_5_Up     : return Input_Button {.Mouse_5, .Left, mods, .Up}
        }

        unreachable()
}

@(private="file")
Keystroke_Flags :: bit_field u32 {
        repeat           : u16 | 16,
        scancode         : u8 | 8,
        extended_key     : b8 | 1,
        _                : u8 | 4,
        context_code     : b8 | 1,
        previous_down    : b8 | 1,
        transition_state : b8 | 1,
}

@(private="file")
Key_State :: bit_field i16 {
        is_toggled : bool | 1,
        _          : u16  | 14,
        is_pressed : bool | 1,
}

@(private="file")
RawInput_Type :: enum win.DWORD {
        Mouse    = 0,
        Keyboard = 1,
        Hid      = 2,
}

@(private="file")
RawInput_Mouse_Button_Flag :: enum win.USHORT {
        Left_Down         = 0,
        Left_Up           = 1,
        Right_Down        = 2,
        Right_Up          = 3,
        Middle_Down       = 4,
        Middle_Up         = 5,
        Button_4_Down     = 6,
        Button_4_Up       = 7,
        Button_5_Down     = 8,
        Button_5_Up       = 9,
        Scroll_Vertical   = 10,
        Scroll_Horizontal = 11,
}

@(private="file")
RawInput_Mouse_Button_Flags :: bit_set[RawInput_Mouse_Button_Flag; win.USHORT]


@(private="file")
_dispatch_raw_mouse :: proc "contextless" (hwnd: win.HWND, raw_mouse: win.RAWMOUSE) {
        runner := _wndproc_runner_from_user_data(hwnd)
        context = runner.ctx

        if raw_mouse.usFlags != win.MOUSE_MOVE_RELATIVE {
                return
        }
        // Mouse movement
        if raw_mouse.lLastX != 0 || raw_mouse.lLastY != 0 {
                context = _wndproc_runner_from_user_data(hwnd).ctx
                event := Input_Event {
                        window    = {{hwnd}},
                        device_id = 0,
                        event = Input_Vector2 {
                                source = .Mouse_Move_Raw,
                                value  = {f32(raw_mouse.lLastX), f32(raw_mouse.lLastY)},
                        }
                }

                _dispatch_callisto_event(hwnd, event)
        }

        // Mouse buttons
        buttons := transmute(RawInput_Mouse_Button_Flags)(raw_mouse.usButtonFlags)
        mods := _get_input_modifiers()

        for button in buttons {
                event := Input_Event {
                        window    = {{hwnd}},
                        device_id = 0,
                }

                if button == .Scroll_Vertical || button == .Scroll_Horizontal {
                        _dispatch_raw_scroll_wheel(hwnd, runner, button, raw_mouse.usButtonData)
                } else {
                        event.event = _input_button_mouse_translate(button, raw_mouse.usButtonData, mods)
                        _dispatch_callisto_event(hwnd, event)
                }
        }
}


// Keeps track of accumulated scroll distance in case the mouse has a smooth-scrolling wheel/trackpad.
// We still need to be able to send discrete wheel button presses for actions such as scrolling through
// inventory items.
@(private="file")
_dispatch_raw_scroll_wheel :: proc (hwnd: win.HWND, runner: ^Runner, button: RawInput_Mouse_Button_Flag, data: win.USHORT) {
        mods := _get_input_modifiers()
        event := Input_Event {
                window = {{hwnd}},
                device_id = 0,
        }

        if button == .Scroll_Vertical {
                scroll_lines: win.UINT
                win.SystemParametersInfoW(win.SPI_GETWHEELSCROLLLINES, 0, &scroll_lines, 0)
                scroll_delta := f32(scroll_lines) * (f32(transmute(win.SHORT)data) / win.WHEEL_DELTA)
                runner.scroll_accumulator.y += scroll_delta

                if runner.scroll_accumulator.y > f32(scroll_lines) {
                        steps := math.floor_f32(runner.scroll_accumulator.y / f32(scroll_lines))
                        runner.scroll_accumulator.y -= steps
                        event.event = Input_Button {
                                source    = .Mouse_Scroll_Up,
                                modifiers = mods,
                                motion    = .Instant,
                        }

                        for i in 0..<int(steps) {
                                _dispatch_callisto_event(hwnd, event)
                        }
                } 
                else if -runner.scroll_accumulator.y > f32(scroll_lines) {
                        steps := math.floor_f32(-runner.scroll_accumulator.y / f32(scroll_lines))
                        runner.scroll_accumulator.y += steps
                        event.event = Input_Button {
                                source    = .Mouse_Scroll_Down,
                                modifiers = mods,
                                motion    = .Instant,
                        }

                        for i in 0..<int(steps) {
                                _dispatch_callisto_event(hwnd, event)
                        }
                }

                
                // Dispatch smooth scroll
                event.event = Input_Vector1 {
                        source    = .Mouse_Scroll_Smooth_Vertical,
                        modifiers = mods,
                        value     = scroll_delta,
                }

                _dispatch_callisto_event(hwnd, event)

        } else if button == .Scroll_Horizontal {
                scroll_chars: win.UINT
                win.SystemParametersInfoW(win.SPI_GETWHEELSCROLLCHARS, 0, &scroll_chars, 0)
                scroll_delta := f32(scroll_chars) * (f32(transmute(win.SHORT)data) / win.WHEEL_DELTA)
                runner.scroll_accumulator.x += scroll_delta

                if runner.scroll_accumulator.x > f32(scroll_chars) {
                        steps := math.floor_f32(runner.scroll_accumulator.x / f32(scroll_chars))
                        runner.scroll_accumulator.x -= steps
                        event.event = Input_Button {
                                source    = .Mouse_Scroll_Right,
                                modifiers = mods,
                                motion    = .Instant,
                        }

                        for i in 0..<int(steps) {
                                _dispatch_callisto_event(hwnd, event)
                        }
                } 
                else if -runner.scroll_accumulator.x > f32(scroll_chars) {
                        steps := math.floor_f32(-runner.scroll_accumulator.x / f32(scroll_chars))
                        runner.scroll_accumulator.x += steps
                        event.event = Input_Button {
                                source    = .Mouse_Scroll_Left,
                                modifiers = mods,
                                motion    = .Instant,
                        }

                        for i in 0..<int(steps) {
                                _dispatch_callisto_event(hwnd, event)
                        }
                }
                
                // Dispatch smooth scroll
                event.event = Input_Vector1 {
                        source    = .Mouse_Scroll_Smooth_Horizontal,
                        modifiers = mods,
                        value     = scroll_delta,
                }

                _dispatch_callisto_event(hwnd, event)
        }
}
