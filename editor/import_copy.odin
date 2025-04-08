package callisto_editor

import "core:os/os2"
import "core:path/filepath"
import "core:log"

// Generic importer for file types that don't require additional processing
import_copy :: proc(args: ^Args, src_filename: string, dir_rel: string, src_fullpath: string, dst_dir_abs: string) -> (ok: bool) {
        dst_path := filepath.join({dst_dir_abs, src_filename})
        defer delete(dst_path)

        os2.mkdir_all(dst_dir_abs)
        err := os2.copy_file(dst_path, src_fullpath)
        if err != {} {
                log.error("Copy failed:", dir_rel, err)
                return false
        }
        return true
}


