package callisto_runner

import "base:runtime"
import "core:dynlib"
import "core:os"
import "core:os/os2"
import "core:io"
import "core:fmt"
import "core:time"
import "core:path/filepath"
import "core:log"

when HOT_RELOAD {


// Used to get absolute path of the game DLL
when ODIN_OS == .Windows {
        DLL_ORIGINAL_FMT :: `{0}\` + GAME_NAME + ".dll"
        DLL_COPY_FMT     :: `{0}\` + GAME_NAME + "_{1}.dll"
} else when ODIN_OS == .Darwin {
        DLL_ORIGINAL_FMT :: "{0}/" + GAME_NAME + ".dylib"
        DLL_COPY_FMT     :: "{0}/" + GAME_NAME + "_{1}.dylib"
} else {
        DLL_ORIGINAL_FMT :: "{0}/" + GAME_NAME + ".so"
        DLL_COPY_FMT     :: "{0}/" + GAME_NAME + "_{1}.so"
}
        

Dll_Error :: enum {
        Ok,
        Unknown,
        Invalid_File,
        File_Not_Found,
        File_In_Use,
        Initialize_Symbols_Failed,
        IO_Error,
}


Dll_Symbol_Table :: struct {
        lib                       : dynlib.Library,
        callisto_runner_callbacks : #type proc() -> Callbacks,
}


Dll_Data :: struct {
        symbol_table    : Dll_Symbol_Table,
        last_modified   : os.File_Time,
        version         : int,
}



main :: proc() {
        ctx, track := _callisto_context()
        defer _callisto_context_end(ctx, track)
        context = ctx

        exe_dir := get_exe_directory()
        defer delete(exe_dir)
        original_dll_path := fmt.aprintf(DLL_ORIGINAL_FMT, exe_dir)
        defer delete(original_dll_path)


        game_state : rawptr

        callbacks, dll_data, err := game_dll_load(0, exe_dir)
        if err != .Ok {
                log.error("DLL load failed:", err)
                return
        }
        
        log.info("Watching", original_dll_path, "at time", dll_data.last_modified)

        callbacks.memory_manager(.Allocate, &game_state)
        callbacks.init(game_state)

        gameloop: 
        for {
                ctl := callbacks.loop(game_state)
                #partial switch ctl {
                case .Shutdown:
                        break gameloop
                case .Reset_Soft:
                        callbacks.memory_manager(.Reset, &game_state)
                        callbacks.init(game_state)
                case .Reset_Hard:
                        callbacks.shutdown(game_state)
                        callbacks.memory_manager(.Free, &game_state)

                        game_dll_unload(dll_data, exe_dir)
                        callbacks, dll_data, err = game_dll_load(dll_data.version, exe_dir)
                        if err != .Ok {
                                log.error("DLL hard reset failed:", err)
                                return
                        }
                       
                        callbacks.memory_manager(.Allocate, &game_state)
                        callbacks.init(game_state)
                }

                        log.info("Hello")

                // watch dll for changes
                if watch_dll_changed(dll_data, original_dll_path) {
                        new_callbacks, new_data, new_err := game_dll_load(dll_data.version + 1, exe_dir)
                        if new_err == .Ok {
                                callbacks = new_callbacks
                                dll_data = new_data
                        } else {
                                log.error("DLL reload failed for version", dll_data.version + 1, ":", new_err)
                        }
                }
        }
        
        callbacks.shutdown(game_state)
        callbacks.memory_manager(.Free, &game_state)
        game_dll_unload(dll_data, exe_dir)
}


watch_dll_changed :: proc(dll_data: Dll_Data, file_name: string) -> (changed: bool) {
        watched_modified, err := os.last_write_time_by_name(file_name)
        log.info(watched_modified)
        if err != os.ERROR_NONE  {
                return false
        }

        return watched_modified > dll_data.last_modified 
}


// Logic from core:os/os2 - will replace with os2 version when it's stable
copy_file :: proc(dst_path, src_path: string) -> (err: Dll_Error) {

        src, res0 := os.open(src_path)
        check_result_os(res0) or_return
        defer os.close(src)

        info, res1 := os.fstat(src)
        check_result_os(res1) or_return
        defer os.file_info_delete(info)
        if info.is_dir {
                return .Invalid_File
        }

        dst, res2 := os.open(dst_path, os.O_RDWR | os.O_CREATE | os.O_TRUNC, int(info.mode) & 0o777)
        check_result_os(res2) or_return
        defer os.close(dst)
        
        _, io_err := io.copy(io.to_writer(os.stream_from_handle(dst)), io.to_reader(os.stream_from_handle(src)))
        if io_err != .None {
                log.error("IO stream copy failed:", err)
                return .IO_Error
        }
        return .Ok
}


check_result_os :: proc(errno: os.Errno) -> Dll_Error {
        switch errno {
        case os.ERROR_NONE:
                return .Ok
        case os.ERROR_NOT_FOUND, os.ERROR_FILE_NOT_FOUND:
                return .File_Not_Found
        case os.ERROR_INVALID_HANDLE:
                return .Invalid_File
        case 32:
                return .File_In_Use
        }

        return .Unknown
}


game_dll_load :: proc(version_number: int, directory: string) -> (callbacks: Callbacks, data: Dll_Data, err: Dll_Error) {
        dll_copy_name := fmt.tprintf(DLL_COPY_FMT, directory, version_number)
        dll_original_name := fmt.tprintf(DLL_ORIGINAL_FMT, directory)
        log.info("Loading DLL:", dll_copy_name)

        copy_file(dll_copy_name, dll_original_name) or_return
        
        last_mod_time, err0 := os.last_write_time_by_name(dll_original_name)
        check_result_os(err0) or_return
        
        data = Dll_Data {
                version       = version_number,
                last_modified = last_mod_time,
        }
        _, ok := dynlib.initialize_symbols(&data.symbol_table, dll_copy_name, handle_field_name="lib")
        if !ok do return {}, {}, .Initialize_Symbols_Failed

        callbacks = data.symbol_table.callisto_runner_callbacks()
        return callbacks, data, .Ok
}


game_dll_unload :: proc(data: Dll_Data, directory: string) {
        dll_copy_name := fmt.tprintf(DLL_COPY_FMT, directory, data.version)
        
        // Probably need a way to fence the game dll if it's multithreaded 
        // to avoid corrupting game state
        
        did_unload := dynlib.unload_library(data.symbol_table.lib)
        did_remove := os.remove(dll_copy_name)
}


get_exe_directory :: proc(allocator := context.allocator) -> string {
        exe := os.args[0]

        if filepath.is_abs(exe) {
                return filepath.dir(exe, allocator)
        } 

        cwd := os.get_current_directory(allocator)
        defer delete(cwd)
        exe_fullpath := filepath.join({cwd, exe}, allocator=allocator)
        defer delete(exe_fullpath)

        return filepath.dir(exe_fullpath, allocator)
}

} // when HOT_RELOAD
