package callisto_runner

import "core:dynlib"
import "core:os"
import "core:path/filepath"

// Used to get absolute path of the game DLL
when ODIN_OS == .Windows {
        DLL_ORIGINAL_FMT :: `{0}\` + APP_NAME + ".dll"
        DLL_COPY_FMT     :: `{0}\` + APP_NAME + "_{1}.dll"
} else when ODIN_OS == .Darwin {
        DLL_ORIGINAL_FMT :: "{0}/" + APP_NAME + ".dylib"
        DLL_COPY_FMT     :: "{0}/" + APP_NAME + "_{1}.dylib"
} else {
        DLL_ORIGINAL_FMT :: "{0}/" + APP_NAME + ".so"
        DLL_COPY_FMT     :: "{0}/" + APP_NAME + "_{1}.so"
}
        

Dll_Result :: enum {
        Ok,
        Unknown,
        Invalid_File,
        File_Not_Found,
        File_In_Use,
        Initialize_Symbols_Failed,
        IO_Error,
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


check_result_os :: proc(errno: os.Errno) -> Dll_Result {
        switch errno {
        case os.ERROR_NONE:
                return .Ok
        case os.ERROR_NOT_FOUND, os.ERROR_FILE_NOT_FOUND:
                return .File_Not_Found
        case os.ERROR_INVALID_HANDLE:
                return .Invalid_File
        case os.Platform_Error(32):
                return .File_In_Use
        }

        return .Unknown
}
