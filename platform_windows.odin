package callisto

import win "core:sys/windows"
import "core:c"
import "core:log"
import "core:path/filepath"
import "core:fmt"
import "core:strings"
import "core:os/os2"
import "config"

Platform :: struct {
        window_icon : win.HICON,
}

Platform_Window :: struct {
        hwnd : win.HWND,
}

exit :: proc(exit_code := Exit_Code.Ok) {
        win.PostQuitMessage(win.INT(exit_code))
}

get_exe_directory :: config.get_exe_directory

get_persistent_directory :: config.get_persistent_directory

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
