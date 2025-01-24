package callisto_common

import "base:intrinsics"
import "base:runtime"
import win "core:sys/windows"
import "core:path/filepath"
import "core:os/os2"
import "../config"
import "core:fmt"

// Allocates using the provided allocator
_get_exe_directory :: proc(allocator := context.allocator) -> (exe_dir: string) {
        buf : [win.MAX_PATH]win.WCHAR
        len := win.GetModuleFileNameW(nil, &buf[0], win.MAX_PATH)

        str, err := win.utf16_to_utf8(buf[:len], context.temp_allocator)
        assert(err == .None && str != "", "Failed to acquire executable directory")

        return filepath.dir(str, allocator)
}

// Allocates using the provided allocator, panics on failure.
_get_persistent_directory :: proc(create_if_not_exist := true, allocator := context.allocator) -> (data_dir: string) {
        path : ^win.WCHAR
        guid := win.FOLDERID_LocalAppData

        hres := win.SHGetKnownFolderPath(&guid, 0, nil, &path)
        defer win.CoTaskMemFree(path)


        assert(win.SUCCEEDED(hres), "Failed to acquire persitent directory")
       
        dir, err := win.wstring_to_utf8(path, -1, context.temp_allocator)
        assert(err == .None && dir != "", "Failed to acquire persistent directory")

        app_dir := filepath.join({dir, config.COMPANY_NAME, config.APP_NAME}, allocator)
        delete(dir, context.temp_allocator)

        if create_if_not_exist {
                err_mkdir := os2.make_directory_all(app_dir)
                assert(err_mkdir == nil || err_mkdir == .Exist, "Failed to create persistent directory")
        }

        return app_dir
}


assert_messagebox :: proc(assertion: bool, message_args: ..any, loc := #caller_location) {
        when !ODIN_DISABLE_ASSERT {
                if !assertion {
                        message := fmt.tprint(..message_args)
                        win.MessageBoxW(nil, win.utf8_to_wstring(message), win.L("Fatal Error"), win.MB_OK)
                        fmt.eprintfln("%v: %v", loc, message)
                        intrinsics.debug_trap()
                        os2.exit(int(win.GetLastError()))
                }
        }
}

parse_hresult :: #force_inline proc(hres: win.HRESULT, allocator := context.temp_allocator) -> string {
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


@(private)
_copy_directory :: proc(dst_dir, src_dir: string) -> Result {
        // These need to be double-null terminated
        src_dir_w := win.utf8_to_wstring(fmt.tprintf("%s\x00", src_dir), context.temp_allocator)
        dst_dir_w := win.utf8_to_wstring(fmt.tprintf("%s\x00", dst_dir), context.temp_allocator)

        fileop := win.SHFILEOPSTRUCTW {
                hwnd   = nil,
                wFunc  = win.FO_COPY,
                pFrom  = src_dir_w,
                pTo    = dst_dir_w,
                fFlags = win.FOF_NO_UI,
        }
        res := win.SHFileOperationW(&fileop)
        if res != 0 {
                return .Platform_Error
        }

        return .Ok
}
