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

exit :: proc(exit_code := Exit_Code.Ok) {
        win.PostQuitMessage(win.INT(exit_code))
}

// Allocates using the provided allocator
get_exe_directory :: proc(allocator := context.allocator) -> (exe_dir: string, res: Result) {
        buf : [win.MAX_PATH]win.WCHAR
        len := win.GetModuleFileNameW(nil, &buf[0], win.MAX_PATH)

        str, err := win.utf16_to_utf8(buf[:len], context.temp_allocator)
        check_error(err) or_return 

        return filepath.dir(str, allocator), .Ok
}

// Allocates using the provided allocator
get_persistent_directory :: proc(allocator := context.allocator) -> (data_dir: string, res: Result) {
        path : win.PWSTR
        guid := win.FOLDERID_LocalAppData

        hres := win.SHGetKnownFolderPath(&guid, win.DWORD(win.KNOWN_FOLDER_FLAG.CREATE), nil, (^win.LPWSTR)(&path))

        dir, err := win.wstring_to_utf8(path, win.MAX_PATH, allocator)
        check_error(err) or_return

        app_dir := filepath.join({dir, COMPANY_NAME, APP_NAME}, allocator)
        delete(dir, allocator)

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
