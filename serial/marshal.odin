package callisto_serial

import "core:io"
import "core:strings"
import "base:runtime"


marshal_into :: proc {
        marshal_into_bytes,
        marshal_into_builder,
        marshal_into_writer,
        marshal_into_encoder,
}

marshal :: marshal_into


marshal_into_bytes :: proc(v: any, allocator := context.allocator, temp_allocator := context.temp_allocator, loc := #caller_location) -> (data: []u8, err: Serial_Error) {
        b, alloc_err := strings.builder_make(allocator, loc)
        if alloc_err != nil {
                return nil, .Allocator_Error
        }

        defer if err != nil {
                strings.builder_destroy(&b)
        }

        if err = marshal_into_builder(&b, v, temp_allocator); err != nil {
                return
        }

        return b.buf[:], nil
}


marshal_into_builder :: proc(b: ^strings.Builder, v: any, temp_allocator := context.temp_allocator) -> Serial_Error {
        w := strings.to_writer(b)
        return marshal_into_writer(w, v)
}


marshal_into_writer :: proc(w: io.Writer, v: any, temp_allocator := context.temp_allocator) -> Serial_Error {
        e, alloc_err := encoder_make(w, temp_allocator)
        if alloc_err != nil {
                return .Allocator_Error
        }

        return marshal_into_encoder(&e, v)
}


marshal_into_encoder :: proc(e: ^Encoder, v: any) -> Serial_Error {
        _encode_type_info(e, type_info_of(v.id)) or_return

        return _encode_data(e, v) 
}
