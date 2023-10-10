package callisto_asset

import "core:mem"
import cc "../common"

Asset :: struct {
    name: string,
    uuid: cc.Uuid,
    type: Type,
}

// TODO: Explicitly set enum values
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

Galileo_Extension_Info :: struct #packed {
    name                : [16]u8,
    version             : u32,
    data_begin_index    : u64,
    next                : u32,
}


Material            :: struct {
    // style: pbr, npr
}

Texture             :: struct {
    
}

// "prefab" or "actor", a fixed transform hierarchy. Can have hardpoints where reparenting is needed.
Construct           :: struct {

}
