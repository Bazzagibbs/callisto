package callisto_asset

import "core:mem"
import cc "../common"


Model               :: struct {
    mesh        : ^Mesh,
    materials   : []^Material,
}

// ###########################
// ## MESH ###################
// ###########################

Mesh                :: struct {
    bounds              : cc.Axis_Aligned_Bounding_Box,
    vertex_groups       : []Vertex_Group,   // Each vertex group has its own draw call, and accesses a subset of the index/vertex buffers.
    buffer              : []u8,
}

Vertex_Group        :: struct {
    bounds          : cc.Axis_Aligned_Bounding_Box,
    buffer_slice    : []u8,
    
    // These are slices into the mesh buffer
    index           : []u32,
    position        : [][3]f32,
    normal          : [][3]f32,
    tangent         : [][4]f32,
    uv              : [][][2]f32,
    color           : [][][4]u8,
    joints          : [][][4]u16, 
    weights         : [][][4]u16,
}

// ###########################
// ## MATERIAL ###############
// ###########################
Material            :: struct {
    // style: pbr, npr
}

Texture             :: struct {
    
}

// "prefab" or "actor", a fixed transform hierarchy. Can have hardpoints where reparenting is needed.
Construct           :: struct {

}
