package callisto_common

import "base:runtime"
import "core:log"
import "core:encoding/uuid"
import "core:os/os2"
import "core:os"
import "core:path/filepath"


check_result :: proc {
        check_result_os2,
}

check_result_os2 :: proc(err: os2.Error, message: string, location := #caller_location) -> Result {
        if err == nil {
                return .Ok
        }

        log.error(message, ":", os2.error_string(err), location = location)

        if err != nil {
                #partial switch e in err {
                        case os2.General_Error:
                        #partial switch e {
                        case .Not_Exist: 
                                return .File_Not_Found
                        case .Invalid_Dir, .Invalid_File, .Invalid_Path: 
                                return .File_Invalid
                        case .Permission_Denied: 
                                return .Permission_Denied
                        }
                }
        }

        return .Unknown_Error
}

uuid_generate :: proc(gen := context.random_generator) -> Uuid {
        id := uuid.generate_v4()
        return transmute(Uuid)id
}

// Allocates using the provided allocator
get_exe_directory :: proc(allocator := context.allocator) -> string {
        return _get_exe_directory(allocator)
}

// Returns the path to the OS-specific application data directory.
//
// - Windows: `%localappdata%\COMPANY_NAME\APP_NAME\`
//
// Allocates using the provided allocator.
get_persistent_directory :: proc(create_if_not_exist := true, allocator := context.allocator) -> string {
        return _get_persistent_directory(create_if_not_exist, allocator)
}

copy_directory :: proc(dst_dir: string, src_dir: string) -> Result {
        return _copy_directory(dst_dir, src_dir)

        // Walk_Userdata :: struct {
        //         allocator: runtime.Allocator,
        //         src_abs: string,
        //         dst_abs: string,
        // }
        //
        // walk_proc :: proc(info: os.File_Info, in_err: os.Error, user_data: rawptr) -> (err: os.Error, skip_dir: bool) {
        //         if in_err != nil {
        //                 return in_err, false
        //         }
        //
        //         data := (^Walk_Userdata)(user_data)
        //         
        //         // Get path relative to src_dir
        //         path_rel, err2 := filepath.rel(data.src_abs, info.fullpath, data.allocator)
        //         if err != nil {
        //                 log.error("Error getting relative path:", err2, data.src_abs, info.fullpath)
        //                 return os.General_Error.Invalid_Path, false 
        //         }
        //         defer delete(path_rel, data.allocator)
        //
        //
        //         dst_fullpath := filepath.join({data.dst_abs, path_rel}, data.allocator)
        //         defer delete(dst_fullpath, data.allocator)
        //
        //         // If this is a directory, check if the corresponding output directory exists
        //         if info.is_dir {
        //
        //                 if os2.exists(dst_fullpath) {
        //                         // Exists and is not a directory, error
        //                         if !os2.is_dir(dst_fullpath) {
        //                                 return os.General_Error.Invalid_Dir, false
        //                         }
        //                         // Otherwise the dir exists, ok
        //                 } else {
        //                         // Doesn't exist, create a new dir
        //                         err4 := os2.make_directory_all(dst_fullpath)
        //                         if err4 != nil {
        //                                 log.errorf("Error creating directory: %v (%v)", err4, dst_fullpath)
        //                                 return os.General_Error.Invalid_Dir, false
        //                         }
        //                 }
        //
        //                 // Don't call copy_file the dir itself
        //                 return nil, false
        //         }
        //
        //         // Copy the current file
        //         err3 := os2.copy_file(dst_fullpath, info.fullpath)
        //         if err3 != nil {
        //                 log.errorf("Error copying file: %v (dst: %v, src: %v)", err3, dst_fullpath, info.fullpath)
        //                 return os.General_Error.Invalid_Path, false
        //         }
        //
        //         return nil, false
        // }
        //
        //
        // walk_data := Walk_Userdata {
        //         allocator = allocator,
        // }
        // ok := true
        //
        // walk_data.src_abs, ok = filepath.abs(src_dir, allocator)
        // if !ok || !os2.is_dir(walk_data.src_abs) {
        //         log.error("Invalid src directory:", src_dir, location = location)
        //         return .File_Invalid
        // }
        // defer delete(walk_data.src_abs, allocator)
        //
        // walk_data.dst_abs, ok = filepath.abs(dst_dir, allocator)
        // if !ok {
        //         log.error("Invalid dst directory:", dst_dir, location)
        //         return .File_Invalid
        // }
        // defer delete(walk_data.src_abs, allocator)
        //
        //
        // err := filepath.walk(src_dir, walk_proc, &walk_data)
        // if err != nil {
        //         return .Platform_Error
        // }
        //
        // return .Ok
}
