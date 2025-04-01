package callisto_common

import "core:os/os2"
import "core:log"

Result :: enum {
        Ok,
        Unknown_Error,
        Unknown_RHI_Error,
        User_Interrupt,
        File_Not_Found,
        File_Invalid, // File exists but is not valid
        Argument_Invalid,
        Argument_Not_Supported, // e.g. triple-buffered vsync on some devices
        State_Invalid, // Some state is not currently configured to allow an operation
        Parse_Error,
        Permission_Denied,
        No_Suitable_GPU,
        Out_Of_Memory_CPU,
        Out_Of_Memory_GPU,
        Out_Of_Disk_Storage,
        Memory_Map_Failed,
        Device_Not_Responding,
        Device_Disconnected,
        Platform_Error,
        Swapchain_Rebuilt,
        Synchronization_Error,
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
