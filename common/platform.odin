package callisto_common

import "core:os/os2"

copy_directory :: proc(dst_path, src_path: string) -> os2.Error {
        return _copy_directory(dst_path, src_path)
}
