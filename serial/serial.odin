package callisto_serial

import "core:encoding/cbor"
import "core:relative"

Serial_Error :: enum {
        None,
        Allocator_Error,
}

Asset_File :: struct {
        header          : File_Header,
        manifest_buffer : []u8,
        data_buffer     : []u8,
}

Asset_Flag :: enum u16 {
        Has_Recoverable_Fields = 0,
        Has_Relative_Pointers  = 1,
}

Asset_Flags :: bit_set[Asset_Flag; u16]


Field_Type :: enum u8 {
        U8,
        U16,
        U32,
        U64,
        U128,

        I8,
        I16,
        I32,
        I64,
        I128,

        B8,
        B16,
        B32,
        B64,
        
        F16,
        F32,
        F64,

        Rune,

        Complex32,
        Complex64,
        Complex128,

        Quaternion64,
        Quaternion128,
        Quaternion256,

        Struct,
        Fixed_Array,
        Enumerated_Array,

        String,
        Slice,
        Pointer,
        Map,
}


Field_Layout :: enum u8 {
        Endian_Little = 0,
        Endian_Big    = 1,

        Align_8       = 0,
        Align_16      = 1,
        Align_32      = 2,
        Align_64      = 3,
}


Field_Info :: bit_field u8 {
        type    : Field_Type   | 6,
        layout  : Field_Layout | 2,
}



File_Header :: struct #packed {
        flags       : Asset_Flags,
        field_count : u16,
        data        : relative.Slice([]u8, int),
        // field tree in the next [data.offset]u8 bytes
}

File_Field :: struct #packed {
        field_info : Field_Info,
        name       : Relative_String(u16),
        children   : relative.Slice([]File_Field, u16),
}

// asset_load_raw :: proc(file: ^os2.File) -> (asset: Asset_File, err: Error) {
// }
//
// asset_free :: proc(asset: Asset_File) {
//         
// }

