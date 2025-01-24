package callisto_editor

import "core:log"
import "core:encoding/json"
import "core:io"
import "ufbx"
import "../common"


check_result :: proc {
        common.check_result_os2,
        check_result_ufbx,
        check_result_json_marshal,
        check_result_json_unmarshal,
}

check_result_ufbx :: proc(u_err: ^ufbx.Error, message: string, location := #caller_location) -> Result {
        if u_err.type == .NONE {
                return .Ok
        }

        log.error(message, ":", u_err.description, location = location)
        switch u_err.type {
        case .NONE, .UNKNOWN: 
                return .File_Invalid
        case .FILE_NOT_FOUND, .EXTERNAL_FILE_NOT_FOUND: 
                return .File_Not_Found
        case .EMPTY_FILE: 
                return .File_Invalid
        case .OUT_OF_MEMORY, .MEMORY_LIMIT, .ALLOCATION_LIMIT:
                return .Out_Of_Memory_CPU
        case .TRUNCATED_FILE:
                return .File_Invalid
        case .IO:
                return .Platform_Error
        case .CANCELLED:
                return .User_Interrupt
        case .UNRECOGNIZED_FILE_FORMAT:
                return .File_Invalid
        case .UNINITIALIZED_OPTIONS:
                return .Argument_Invalid
        case .ZERO_VERTEX_SIZE, .TRUNCATED_VERTEX_STREAM, .INVALID_UTF8:
                return .Argument_Invalid
        case .FEATURE_DISABLED:
                return .State_Invalid
        case .BAD_NURBS:
                return .Argument_Invalid
        case .BAD_INDEX:
                return .File_Invalid
        case .NODE_DEPTH_LIMIT:
                return .State_Invalid
        case .THREADED_ASCII_PARSE:
                return .File_Invalid
        case .UNSAFE_OPTIONS:
                return .State_Invalid
        case .DUPLICATE_OVERRIDE:
                return .Argument_Invalid
        }

        return .File_Invalid
}


check_result_json_marshal :: proc(err: json.Marshal_Error, message: string, location := #caller_location) -> Result {
        if err == nil {
                return .Ok
        }

        log.error(message, ":", err, location = location)

        switch e in err {
        case json.Marshal_Data_Error:
                return .Parse_Error
        case io.Error:
                return .Platform_Error
        }

        return .Unknown_Error
}


check_result_json_unmarshal :: proc(err: json.Unmarshal_Error, message: string, location := #caller_location) -> Result {
        if err == nil || err == json.Error.EOF {
                return .Ok
        }

        log.error(message, ":", err, location = location)

        switch e in err {
        case json.Error:
                switch e {
                case .None, .EOF                                    : return .Ok
                case .Out_Of_Memory                                 : return .Out_Of_Memory_CPU
                case .Invalid_Allocator                             : return .State_Invalid
                case .Illegal_Character..=.Expected_Colon_After_Key : return .Parse_Error
                }
                return .Parse_Error
        case json.Unmarshal_Data_Error:
                switch e {
                case .Invalid_Data          : return .File_Invalid
                case .Invalid_Parameter     : return .Argument_Invalid
                case .Multiple_Use_Field    : return .Parse_Error
                case .Non_Pointer_Parameter : return .Argument_Invalid
                }
        case json.Unsupported_Type_Error: 
                return .Parse_Error
        }

        return .Unknown_Error
}
