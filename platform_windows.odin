package callisto

import win "core:sys/windows"
import "core:c"
import "core:log"
import "core:path/filepath"
import "core:fmt"
import "core:strings"
import "core:os/os2"

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
get_exe_directory :: proc(allocator := context.allocator) -> (exe_dir: string) {
        buf : [win.MAX_PATH]win.WCHAR
        len := win.GetModuleFileNameW(nil, &buf[0], win.MAX_PATH)

        str, err := win.utf16_to_utf8(buf[:len], context.temp_allocator)
        assert(err == .None && str != "", "Failed to acquire executable directory")

        return filepath.dir(str, allocator)
}

// Allocates using the provided allocator, panics on failure.
get_persistent_directory :: proc(create_if_not_exist := true, allocator := context.allocator) -> (data_dir: string) {
        path : ^win.WCHAR
        guid := win.FOLDERID_LocalAppData

        hres := win.SHGetKnownFolderPath(&guid, 0, nil, &path)
        defer win.CoTaskMemFree(path)


        assert(check_hresult(hres) == .Ok, "Failed to acquire persitent directory")
       
        dir, err := win.wstring_to_utf8(path, -1, allocator)
        assert(err == .None && dir != "", "Failed to acquire persistent directory")

        app_dir := filepath.join({dir, COMPANY_NAME, APP_NAME}, allocator)
        delete(dir, allocator)

        if create_if_not_exist {
                err_mkdir := os2.make_directory_all(app_dir)
                assert(err_mkdir == nil || err_mkdir == .Exist, "Failed to create persistent directory")
        }

        return app_dir
}

check_hresult :: proc (hres: win.HRESULT, fail := Result.Platform_Error, loc := #caller_location) -> Result {
        if win.SUCCEEDED(hres) {
                return .Ok
        }

        log.errorf("[HRESULT] (Fac: %v) (Code: %x) %s", _format_hresult(hres), location = loc)
        return fail
}

@(private)
_format_hresult :: proc (hres: win.HRESULT, allocator := context.temp_allocator) -> (facility: win.FACILITY, code: int, message: string) {
        buf: win.wstring

        _, facility, code = win.DECODE_HRESULT(hres)

        msg_len := win.FormatMessageW(
                flags   =  win.FORMAT_MESSAGE_FROM_SYSTEM | win.FORMAT_MESSAGE_IGNORE_INSERTS | win.FORMAT_MESSAGE_ALLOCATE_BUFFER,
                lpSrc   =  nil,
                msgId   =  u32(hres),
                langId  =  0,
                buf     =  (win.LPWSTR)(&buf),
                nsize   =  0,
                args    =  nil
        )

        message, _ = win.utf16_to_utf8(buf[:msg_len], allocator)
        win.LocalFree(buf)

        return
}
