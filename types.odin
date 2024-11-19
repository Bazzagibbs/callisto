package callisto

import "core:mem"

Result :: enum {
        Ok,
        File_Not_Found,
        File_Invalid, // File exists but is not valid
        Argument_Invalid,
        Parse_Error,
        Permission_Denied,
        Hardware_Not_Suitable,
        Out_Of_Memory,
        Out_Of_Disk_Storage,
        Device_Not_Responding,
        Device_Disconnected,
        Platform_Error,
}

translate_error :: proc {
        translate_error_allocator,
}

translate_error_allocator :: proc "contextless" (err: mem.Allocator_Error) -> Result {
        switch err {
        case .None, .Mode_Not_Implemented: 
                return .Ok

        case .Out_Of_Memory: 
                return .Out_Of_Memory

        case .Invalid_Pointer, .Invalid_Argument: 
                return .Argument_Invalid
        }

        return .Ok
}
