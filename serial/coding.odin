package callisto_serial

import "base:runtime"
import "base:builtin"
import "core:io"
import "core:container/queue"


// Decoder :: struct {
//         // flags  : Decoder_Flags,
//         reader    : io.Reader,
//         allocator : runtime.Allocator,
// }

Encoder :: struct {
        // flags: Encoder_Flags,
        writer         : io.Writer,
        temp_allocator : runtime.Allocator,
        copy_queue     : queue.Queue(runtime.Raw_Slice),
        written        : int,
        relative_cursor: int,
}

encoder_make :: proc(w: io.Writer, temp_allocator := context.temp_allocator) -> (e: Encoder, err: runtime.Allocator_Error) {
        e = Encoder {
                writer         = w,
                temp_allocator = temp_allocator,
        }

        if err = queue.init(&e.copy_queue, allocator = e.temp_allocator); err != nil {
                return {}, err
        }

        return e, nil
}

encoder_destroy :: proc(e: ^Encoder) {
        queue.destroy(&e.copy_queue)
        e^ = {}
}

_encode_type_info :: proc(e: ^Encoder, ti: ^runtime.Type_Info) -> Serial_Error {
        ti := runtime.type_info_core(ti)
        #partial switch info in ti.variant {
        case runtime.Type_Info_Named, runtime.Type_Info_Enum, runtime.Type_Info_Bit_Field:
                unreachable()

        case runtime.Type_Info_Pointer:
                // - t: pointer
                // - next: ^target type
                // return _encode_type_pointer(e, info)

        case runtime.Type_Info_Slice, runtime.Type_Info_String:
                // - t: slice
                // - next: ^target type
                // return _encode_type_slice(e, info)

        case runtime.Type_Info_Integer:
                // - t: uint/int
                // - next: size
        case runtime.Type_Info_Float:
                // - t: float
                // - next: size
        case runtime.Type_Info_Rune:
                // - t: rune
                // - next: 
        case runtime.Type_Info_Boolean:
                // - t: bool
                // - next: size
        case runtime.Type_Info_Array:
                // - t: array
                // - next: ^target type
        case runtime.Type_Info_Enumerated_Array:
                // - t: enum_array
                // - next: 
        }

        unimplemented()
}


_encode_data :: proc(e: ^Encoder, v: any) -> Serial_Error {
        // Breadth first search of the type tree.
        // Pointers/slices/strings are changed into self-relative versions.
        // Dynamic structures are compressed into slices.

        unimplemented()
}
