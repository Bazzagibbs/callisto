package callisto_config

import win "core:sys/windows"
import "core:path/filepath"
import "core:os/os2"

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


        assert(win.SUCCEEDED(hres), "Failed to acquire persitent directory")
       
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
