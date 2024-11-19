package callisto

import win "core:sys/windows"
import "core:c"
import "core:log"
import "core:path/filepath"
import "core:fmt"
import "core:strings"

Platform :: struct {
        window_icon : win.HICON,
}

Platform_Window :: struct {
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

// Allocates using the provided allocator
get_exe_directory :: proc(allocator := context.allocator) -> (exe_dir: string, res: Result) {
        buf : [win.MAX_PATH]win.WCHAR
        len := win.GetModuleFileNameW(nil, &buf[0], win.MAX_PATH)

        str, err := win.utf16_to_utf8(buf[:len], context.temp_allocator)
        translate_error(err) or_return 

        return filepath.dir(str, allocator), .Ok
}

// Allocates using the provided allocator
get_persistent_directory :: proc(allocator := context.allocator) -> (data_dir: string, res: Result) {
        buf : [win.MAX_PATH]win.WCHAR

        guid := win.FOLDERID_LocalAppData
        win.SHGetKnownFolderPath(&guid, 0, nil, (^^u16)(&buf[0]))

        dir, err := win.utf16_to_utf8(buf[:], context.temp_allocator)
        translate_error(err) or_return

        app_dir := filepath.join({dir, COMPANY_NAME, APP_NAME}, allocator)
        return app_dir, .Ok
}

@(private)
_format_hresult :: proc (hres: win.HRESULT, allocator := context.temp_allocator) -> string {
        buf: win.wstring

        msg_len := win.FormatMessageW(
                flags   =  win.FORMAT_MESSAGE_FROM_SYSTEM | win.FORMAT_MESSAGE_IGNORE_INSERTS | win.FORMAT_MESSAGE_ALLOCATE_BUFFER,
                lpSrc   =  nil,
                msgId   =  u32(hres),
                langId  =  0,
                buf     =  (win.LPWSTR)(&buf),
                nsize   =  0,
                args    =  nil
        )

        out_str, _ := win.utf16_to_utf8(buf[:msg_len], allocator)
        win.LocalFree(buf)

        return out_str
}
