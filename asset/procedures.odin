package callisto_asset

import "core:os"
import "core:runtime"
import "core:intrinsics"
import "core:log"
import "core:io"
import "core:mem"
import cc "../common"

read_metadata :: proc(file_reader: io.Reader, asset: ^Asset) -> (ok: bool) {

    // Magic (4 bytes) should be "GALI"
    temp_magic: [4]u8
    io.read(file_reader, temp_magic[:])
    // if temp_magic != {'G', 'A', 'L', 'I'} {
    if temp_magic != "GALI" {
        return false
    }

    spec_ver: u32
    io.read_ptr(file_reader, &spec_ver, 4)

    io.read_ptr(file_reader, &asset.uuid, 16)
    io.read_ptr(file_reader, &asset.type, 4)
    
    checksum: u64
    io.read_ptr(file_reader, &checksum, 4)

    return true
}

load :: proc($T: typeid, file_path: string) -> (loaded_asset: T, ok: bool)
    where intrinsics.type_is_subtype_of(T, Asset) #optional_ok {

    file, file_errno := os.open(file_path)
    if file_errno != os.ERROR_NONE {
        log.error("Could not load asset", file_path, ", Error:", file_errno)
        return {}, false
    }
    defer os.close(file)

    file_reader := io.to_reader(os.stream_from_handle(file))


    ok_header: bool
    loaded_asset, ok_header = read_metadata(T, file_reader)
    if ok_header == false {
        log.error("Could not load asset because of bad header:", file_path)
        return {}, false
    }

    switch typeid_of(T) {
        case Mesh:
            // assert loaded_asset.type == .mesh
            ok = load_mesh_body(file_reader, &loaded_asset)
            return
        case:
            log.error("Can't load unsupported asset type", type_info_of(typeid_of(T)))
            return {}, false
    }
}

unload :: proc(loaded_asset: ^$T) 
    where intrinsics.type_is_subtype_of(T, Asset) {
    delete(loaded_asset)
}

make_subslice_of_type :: proc($T: typeid, data_buffer: []u8, cursor: ^int, length: int) -> (subslice: []T) {
    stride := size_of(T)                                                       
    subslice = transmute([]T) mem.Raw_Slice{&data_buffer[cursor^], length}
    cursor^ += stride * length
    return subslice
}                                                       

new_struct_in_buffer :: proc($T: typeid, buffer: []u8, cursor: ^int) -> (new_struct: ^T) {
    new_struct = transmute(^T) &buffer[cursor^] 
    cursor^ += size_of(T)
    return
}

get_subslice_offset :: proc(base, subslice: []u8) -> int {
    return mem.ptr_sub(raw_data(subslice), raw_data(base))
}
