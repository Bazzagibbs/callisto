package callisto_asset

import "base:intrinsics"
import "core:slice"

// A cursor is held for the allocation buffer.

// Struct serialization happens in the following order:
// Struct members
// - builtin numbers, bools, enums and (recursive) structs
// - slices and strings (ptr and length ONLY)
//      - ptr is the current cursor value
//      - cursor is incremented by length * size_of(element)
//      - slice is pushed to a queue to be serialized later

Buffer_Index :: u64

Serialized_Slice :: struct {
    data   : Buffer_Index,
    length : i64, // number of elements, NOT byte size
}

// Serialize structs, slices, enums and number types.
serialize :: proc(buffer: []u8, data: ^$T, base_cursor, buffer_cursor: ^u64) {
    // structs, enums and numbers always write to the base cursor.
    // slices write metadata to the base cursor, and data to the buffer cursor.
    // - When serializing slice data, the old buffer cursor becomes its base cursor.

    if intrinsics.type_is_slice(T) {
        serialize_slice(buffer, data, base_cursor, buffer_cursor)
    } 
    else if intrinsics.type_is_struct(T) {
        serialize_struct(buffer, data, base_cursor)
    }
    else {}
    // else if intrinsics.type_is_enum(T) {}

}


serialize_struct :: proc(buffer: []u8, data: ^$T, base_cursor: ^u64) {
    buffer_cursor := base_cursor^ + size_of(T)
    // Loop over members of T and call serialize() on each.
    // buffer_cursor^ = 
    
    unimplemented()
}


serialize_slice :: proc(buffer: []u8, slice: ^$S/[]$T, base_cursor, buffer_cursor: ^u64) {
    // Write this with base cursor 
    // data := 
    //
    // cursor_internal := buffer_slice.data
    // cursor^ += buffer_slice.length
    //
    // // Write this with buffer cursor
    // for &element in slice {
    //     serialize(buffer, &element, &buffer_cursor, &buffer_cursor)
    // }
    //
    // return buffer_slice
}


