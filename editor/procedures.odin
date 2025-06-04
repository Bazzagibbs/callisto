package callisto_editor

import "core:log"
import "core:encoding/json"
import "core:encoding/cbor"
import "core:io"
import "core:os/os2"
// import "ufbx"
import "../common"
import "core:path/filepath"
import cmp "compressonator"


// Translate error values into cal.Result and log the error
check_result :: proc {
        common.check_result_os2,
}

// Translate error values into an ok bool and log the error
check_ok :: proc {
        check_ok_json_marshal,
        check_ok_json_unmarshal,
        check_ok_cmp,
}


check_ok_json_marshal :: proc(err: json.Marshal_Error, message: string = "", location := #caller_location) -> (ok: bool) {
        if err == nil {
                return true
        }

        log.error(message, ":", err, location = location)
        return false
}


check_ok_json_unmarshal :: proc(err: json.Unmarshal_Error, message: string = "", location := #caller_location) -> (ok: bool) {
        if err == nil || err == json.Error.EOF {
                return true
        }

        log.error(message, ":", err, location = location)
        return false
}

check_ok_cmp :: proc(err: cmp.Error, message: string = "", location := #caller_location) -> (ok: bool) {
        if err == .OK {
                return true
        }
        log.error(message, ":", err, location = location)
        return false
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

        // modified os2.read_entire_file_from_file, appending a zero byte to the end
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


