package callisto_asset

import "core:mem"
import cc "../common"

Asset :: struct {
    name: string,
    uuid: cc.Uuid,
    type: Asset_Type,
}

// TODO: Explicitly set enum values
Asset_Type :: enum(u32) {
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


Material            :: struct {
    // style: pbr, npr
}

Texture             :: struct {
    
}

// "prefab" or "actor", a fixed transform hierarchy. Can have hardpoints where reparenting is needed.
Construct           :: struct {

}
