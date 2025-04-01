package callisto_common

import "core:os/os2"
import win "core:sys/windows"
import "core:fmt"

@(private)
_copy_directory :: proc(dst_dir, src_dir: string) -> os2.Error {
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
                return os2.Platform_Error(res)
        }

        return {}
}

