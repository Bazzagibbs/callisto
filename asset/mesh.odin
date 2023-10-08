package callisto_asset
import cc "../common"

Mesh                :: struct {
    using asset         : Asset,
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
    texcoords       : [][][2]f32,
    colors          : [][][4]u8,
    joints          : [][][4]u16, 
    weights         : [][][4]u16,
}

// Allocates using context allocator
make_mesh :: proc(vertex_group_count, buffer_size: int) -> Mesh {
    mesh := Mesh {
        type          = .mesh,
        vertex_groups = make([]Vertex_Group, vertex_group_count),
        buffer        = make([]u8, buffer_size),
    }

    return mesh
}


delete_mesh :: proc(mesh: ^Mesh) {
    for vert_group in mesh.vertex_groups {
        if len(vert_group.texcoords) > 0    do delete(vert_group.texcoords)
        if len(vert_group.colors) > 0       do delete(vert_group.colors)
        if len(vert_group.joints) > 0       do delete(vert_group.joints)
        if len(vert_group.weights) > 0      do delete(vert_group.weights)
    }
    delete(mesh.vertex_groups)
    delete(mesh.buffer)
}

// Convert a mesh struct to a Galileo Mesh buffer, which can be written to a file.
// 
// Allocates using provided allocator
serialize_mesh :: proc(mesh: ^Mesh, allocator := context.allocator) -> []u8 {
    return {}
}
