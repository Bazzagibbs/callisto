package callisto

import win "core:sys/windows"
import "core:c"
import "core:log"
import "core:path/filepath"

Platform :: struct {
        window_icon : win.HICON,
}

Window_Platform :: struct {
        hwnd : win.HWND,
}


window_create :: proc(e: ^Engine, create_info: ^Window_Create_Info, out_window: ^Window) -> (res: Result) {
        return e.runner->window_create(create_info, out_window)
}


poll_input :: proc {
        poll_input_application,
        poll_input_window,
}

poll_input_application :: proc(e: ^Engine) {
        msg: win.MSG
        for win.PeekMessageW(&msg, nil, 0, 0, win.PM_REMOVE) {
                win.TranslateMessage(&msg)
                win.DispatchMessageW(&msg)
        }
}

poll_input_window :: proc(e: ^Engine, window: ^Window) {
        msg: win.MSG
        for win.PeekMessageW(&msg, window._platform.hwnd, 0, 0, win.PM_REMOVE) {
                win.TranslateMessage(&msg)
                win.DispatchMessageW(&msg)
        }
}

get_exe_directory :: proc(allocator := context.allocator) -> string {
        buf : [1024]win.WCHAR
        len := win.GetModuleFileNameW(nil, &buf[0], 1024)

        str, _ := win.utf16_to_utf8(buf[:len], context.temp_allocator)

        return filepath.dir(str, allocator)
}
