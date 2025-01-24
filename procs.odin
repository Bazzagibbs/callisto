package callisto

import "core:mem"
import "common"


check_error :: proc {
        check_error_allocator,
}

check_error_allocator :: proc "contextless" (err: mem.Allocator_Error) -> Result {
        switch err {
        case .None, .Mode_Not_Implemented: 
                return .Ok

        case .Out_Of_Memory: 
                return .Out_Of_Memory_CPU

        case .Invalid_Pointer, .Invalid_Argument: 
                return .Argument_Invalid
        }

        return .Ok
}

copy_directory :: common.copy_directory

get_exe_directory        :: common.get_exe_directory
get_persistent_directory :: common.get_persistent_directory

