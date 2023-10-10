package callisto_asset

import "core:os"
import "core:runtime"
import cc "../common"

read_metadata :: proc(file_path: string) -> (metadata: Asset, ok: bool) {
    file, err := os.open(file_path)
    if err != os.ERROR_NONE {
        return {}, false
    }
    defer os.close(file)

    // Magic (4 bytes) should be "GALI"
    temp_magic: [4]u8
    os.read(file, temp_magic[:])
    // if temp_magic != {'G', 'A', 'L', 'I'} {
    if temp_magic != "GALI" {
        return {}, false
    }

    spec_ver: u32
    os.read_ptr(file, &spec_ver, 4)

    os.read_ptr(file, &metadata.uuid, 16)
    os.read_ptr(file, &metadata.type, 4)
    
    checksum: u64
    os.read_ptr(file, &checksum, 4)

    return metadata, true
}

