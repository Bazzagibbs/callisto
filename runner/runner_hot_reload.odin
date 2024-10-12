package callisto_runner

import "base:runtime"
import "core:dynlib"
import "core:os"
import "core:os/os2"
import "core:io"
import "core:fmt"
import "core:time"
import "core:path/filepath"

when HOT_RELOAD {

DLL_BASE :: "game"

when ODIN_OS == .Windows {
        DLL_EXT :: ".dll"
} else when ODIN_OS == .Darwin {
        DLL_EXT :: ".dylib"
} else {
        DLL_EXT :: ".so"
}

DLL_ORIGINAL :: DLL_BASE + DLL_EXT
DLL_ORIGINAL_FMT_STRING :: "{0}" + filepath.SEPARATOR_STRING + DLL_ORIGINAL
DLL_COPY_FMT_STRING :: "{0}" + filepath.SEPARATOR_STRING + DLL_BASE + "_{1}" + DLL_EXT


Dll_Symbol_Table :: struct {
        lib                       : dynlib.Library,
        callisto_runner_callbacks : #type proc() -> Runner_Callbacks,
}

Dll_Data :: struct {
        symbol_table    : Dll_Symbol_Table,
        last_modified   : os.File_Time,
        version         : int,
}



main :: proc() {
        fmt.println("[RUNNER] Starting with hot reload")

        exe_dir := get_exe_directory()
        original_dll_name := fmt.aprintf(DLL_ORIGINAL_FMT_STRING, exe_dir)
        defer delete(exe_dir)
        defer delete(original_dll_name)
                
        game_callbacks            : Runner_Callbacks = {}
        dll_data                  : Dll_Data = {}
        game_state                : rawptr
        ctx                       : runtime.Context
        ok                        : bool

        game_callbacks, dll_data, ok = game_dll_load(0, exe_dir)
        if !ok do return

        game_state, ctx = game_callbacks.memory_init()
        if ctx == {} {
                ctx = runtime.default_context()
        }
        context = ctx
        game_callbacks.game_init()

        gameloop: 
        for {
                ctl := game_callbacks.game_render()
                switch ctl {
                case .Ok:
                case .Shutdown:
                        break gameloop
                case .Reset_Soft:
                        game_state = game_callbacks.memory_reset(game_state)
                        game_callbacks.game_init()
                case .Reset_Hard:
                        game_callbacks.memory_shutdown(game_state)

                        game_dll_unload(dll_data, exe_dir)
                        game_callbacks, dll_data, ok = game_dll_load(dll_data.version, exe_dir)
                        if !ok do return

                        game_state, ctx = game_callbacks.memory_init()
                        if ctx == {} {
                                ctx = runtime.default_context()
                        }
                        context = ctx
                        game_callbacks.game_init()
                }

                // watch dll for changes
                if watch_dll_changed(dll_data, original_dll_name) {
                        new_callbacks, new_data, new_ok := game_dll_load(dll_data.version + 1, exe_dir)
                        if new_ok {
                                game_callbacks = new_callbacks
                                dll_data = new_data
                                game_callbacks.memory_load(game_state)
                        } 
                }
        }
        
        game_callbacks.memory_shutdown(game_state)
        game_dll_unload(dll_data, exe_dir)
}

watch_dll_changed :: proc(dll_data: Dll_Data, file_name: string) -> (changed: bool) {
        watched_modified, err := os.last_write_time_by_name(file_name)
        if err != os.ERROR_NONE  {
                return false
        }

        return watched_modified > dll_data.last_modified 
}

// Logic from core:os/os2 - will replace with os2 version when it's stable
copy_file :: proc(dst_path, src_path: string) -> (ok: bool) {
        check_result_os :: proc(errno: os.Errno, location := #caller_location) -> (ok: bool) {
                if(errno == os.ERROR_NONE) {
                        return true
                }
               
                fmt.println("Error:", errno)
                panic("Error copying file", location)
        }

        src, res0 := os.open(src_path)
        check_result_os(res0) or_return
        defer os.close(src)

        info, res1 := os.fstat(src)
        check_result_os(res1) or_return
        defer os.file_info_delete(info)
        assert(info.is_dir == false, "Error copying file - source file is directory")

        dst, res2 := os.open(dst_path, os.O_RDWR | os.O_CREATE | os.O_TRUNC, int(info.mode) & 0o777)
        check_result_os(res2) or_return
        defer os.close(dst)

        
        _, err := io.copy(io.to_writer(os.stream_from_handle(dst)), io.to_reader(os.stream_from_handle(src)))
        assert(err == .None, "Error copying file")
        return true
}


game_dll_load :: proc(version_number: int, directory: string) -> (callbacks: Runner_Callbacks, data: Dll_Data, ok: bool) {
        dll_copy_name := fmt.tprintf(DLL_COPY_FMT_STRING, directory, version_number)
        dll_original_name := fmt.tprintf(DLL_ORIGINAL_FMT_STRING, directory)
        fmt.println("Loading DLL:", dll_copy_name)

        ok = copy_file(dll_copy_name, dll_original_name)
        assert(ok, "Failed to load DLL - Couldn't copy file")
        
        last_mod_time, err0 := os.last_write_time_by_name(dll_original_name)
        assert(err0 == os.ERROR_NONE, "Failed to load DLL - Couldn't get last write time")
        
        data = Dll_Data {
                version       = version_number,
                last_modified = last_mod_time,
        }
        _, ok = dynlib.initialize_symbols(&data.symbol_table, dll_copy_name, handle_field_name="lib")
        assert(ok, "Failed to load DLL - Couldn't initialize symbols")

        callbacks = data.symbol_table.callisto_runner_callbacks()
        return callbacks, data, true
}


game_dll_unload :: proc(data: Dll_Data, directory: string) {
        dll_copy_name := fmt.tprintf(DLL_COPY_FMT_STRING, directory, data.version)
        
        // Probably need a way to fence the game dll if it's multithreaded 
        // to avoid corrupting game state
        
        did_unload := dynlib.unload_library(data.symbol_table.lib)
        assert(did_unload, "[RUNNER] Failed to unload DLL")
        did_remove := os.remove(dll_copy_name)
        assert(did_remove == os.ERROR_NONE, "[RUNNER] Failed to delete DLL")
}


get_exe_directory :: proc() -> string {
        exe := os.args[0]
        cwd := os.get_current_directory()
        defer delete(cwd)
        exe_fullpath := fmt.tprintf("{0}" + filepath.SEPARATOR_STRING + "{1}", cwd, exe)

        return filepath.dir(exe_fullpath)
}


} // when HOT_RELOAD
