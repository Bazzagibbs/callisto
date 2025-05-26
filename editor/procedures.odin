package callisto_editor

import "core:log"
import "core:encoding/json"
import "core:encoding/cbor"
import "core:io"
import "core:os/os2"
// import "ufbx"
import "../common"
import "core:path/filepath"


check_result :: proc {
        common.check_result_os2,
        // check_result_ufbx,
        check_result_json_marshal,
        check_result_json_unmarshal,
}

// check_result_ufbx :: proc(u_err: ^ufbx.Error, message: string, location := #caller_location) -> Result {
//         if u_err.type == .NONE {
//                 return .Ok
//         }
//
//         log.error(message, ":", u_err.description, location = location)
//         switch u_err.type {
//         case .NONE, .UNKNOWN: 
//                 return .File_Invalid
//         case .FILE_NOT_FOUND, .EXTERNAL_FILE_NOT_FOUND: 
//                 return .File_Not_Found
//         case .EMPTY_FILE: 
//                 return .File_Invalid
//         case .OUT_OF_MEMORY, .MEMORY_LIMIT, .ALLOCATION_LIMIT:
//                 return .Out_Of_Memory_CPU
//         case .TRUNCATED_FILE:
//                 return .File_Invalid
//         case .IO:
//                 return .Platform_Error
//         case .CANCELLED:
//                 return .User_Interrupt
//         case .UNRECOGNIZED_FILE_FORMAT:
//                 return .File_Invalid
//         case .UNINITIALIZED_OPTIONS:
//                 return .Argument_Invalid
//         case .ZERO_VERTEX_SIZE, .TRUNCATED_VERTEX_STREAM, .INVALID_UTF8:
//                 return .Argument_Invalid
//         case .FEATURE_DISABLED:
//                 return .State_Invalid
//         case .BAD_NURBS:
//                 return .Argument_Invalid
//         case .BAD_INDEX:
//                 return .File_Invalid
//         case .NODE_DEPTH_LIMIT:
//                 return .State_Invalid
//         case .THREADED_ASCII_PARSE:
//                 return .File_Invalid
//         case .UNSAFE_OPTIONS:
//                 return .State_Invalid
//         case .DUPLICATE_OVERRIDE:
//                 return .Argument_Invalid
//         }
//
//         return .File_Invalid
// }


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



abs_path_from_project :: proc(args: ^Args, path_rel: string, allocator := context.allocator) -> string {
        return filepath.join({args.project, path_rel}, allocator)
}

abs_path_from_resource :: proc(args: ^Args, path_rel: string, allocator := context.allocator) -> string {
        return filepath.join({args.project, args.resource, path_rel}, allocator)
}

abs_path_from_imported :: proc(args: ^Args, path_rel: string, allocator := context.allocator) -> string {
        return filepath.join({args.project, args.imported, path_rel}, allocator)
}

abs_path_from_out :: proc(args: ^Args, path_rel: string, allocator := context.allocator) -> string {
        return filepath.join({args.project, args.out, path_rel}, allocator)
}

read_entire_file_cstring :: proc(path: string, allocator := context.allocator) -> (data_cstring: cstring, err: os2.Error) {
        f := os2.open(path) or_return
        defer os2.close(f)

        // modified os2.read_entire_file_from_file
        size: int
	has_size := false
	if size64, serr := os2.file_size(f); serr == nil {
		if i64(int(size64)) == size64 {
			has_size = true
			size = int(size64)
		}
	}

	if has_size && size > 0 {
                size += 1 // for null byte
		total: int
		data := make([]byte, size, allocator) or_return
		for total < len(data) - 1 {
			n: int
			n, err = os2.read(f, data[total:])
			total += n
			if err != nil {
				if err == .EOF {
					err = nil
				}
				data = data[:total]
				break
			}
		}
		return cstring(raw_data(data)), err
	} else {
		buffer: [1024]u8
		out_buffer := make([dynamic]u8, 0, 0, allocator)
		total := 0
		for {
			n: int
			n, err = os2.read(f, buffer[:])
			total += n
			append_elems(&out_buffer, ..buffer[:n])
			if err != nil {
				if err == .EOF || err == .Broken_Pipe {
					err = nil
				}
                                append(&out_buffer, 0)
				data := out_buffer[:total]
                                return cstring(raw_data(data)), err
			}
		}
	}
}
