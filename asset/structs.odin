package callisto_asset

import "core:mem"
import cc "../common"

Asset :: struct {
    name: string,
    uuid: cc.Uuid,
    type: Type,
}

// TODO(galileo): Explicitly set enum values
Type :: enum(u32) {
    invalid = 0,
    // Primitives
    mesh,
    image,
    audio,
    shader,
    // Aggregates
    archive,
    material,
    model,
    construct,

    custom,
}

Galileo_Header         :: struct #packed {
    magic                   : [4]u8,
    spec_version_major      : u8,
    spec_version_minor      : u8,
    spec_version_patch      : u16,
    uuid              : cc.Uuid,
    type              : Type,
    body_checksum           : u64,
}

Galileo_Extension_Info :: struct #packed {
    name                : [16]u8,
    version             : u32,
    data_begin_index    : u64,
    next                : u32,
}


