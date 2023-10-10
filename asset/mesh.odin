package callisto_asset

import "core:bufio"
import "core:mem"

import cc "../common"

Galileo_Mesh_Manifest :: struct #packed {
    bounds              : cc.Axis_Aligned_Bounding_Box,
    vertex_group_count  : u32,
    extension_count     : u32,
    buffer_size         : u64,
    next_mesh_extension : u32,
}

Galileo_Vertex_Group_Info :: struct #packed {
    bounds                      : cc.Axis_Aligned_Bounding_Box,
    buffer_slice_begin          : u64,
    buffer_slice_size           : u64,
    
    index_count                 : u32,
    vertex_count                : u32,

    texcoord_channel_count      : u8,
    color_channel_count         : u8,
    joint_weight_channel_count  : u8,

    next_vertex_group_extension : u32,
}


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
    delete(mesh.name)
}

// Convert a mesh struct to a Galileo Mesh buffer, which can be written to a file.
// 
// Allocates using provided allocator
serialize_mesh :: proc(mesh: ^Mesh, allocator := context.allocator) -> (data: []u8) {
    file_buf_size := size_of(Galileo_Mesh_Manifest) + 
                     len(mesh.vertex_groups) * size_of(Galileo_Vertex_Group_Info) + 
                     // n_extensions * size_of(Galileo_Extension_Info) +
                     len(mesh.buffer)

    data = make([]u8, file_buf_size)
    cursor := 0
    
    // Populate mesh manifest
    manifest := new_struct_in_buffer(Galileo_Mesh_Manifest, data, &cursor)
    manifest.bounds = mesh.bounds
    manifest.vertex_group_count = u32(len(mesh.vertex_groups))
    manifest.extension_count = 0
    manifest.buffer_size = u64(len(mesh.buffer))

    // Populate vertex group infos
    for vg in mesh.vertex_groups {
        vg_info := new_struct_in_buffer(Galileo_Vertex_Group_Info, data, &cursor)
        vg_info.bounds = vg.bounds
        vg_info.buffer_slice_begin = u64(get_subslice_offset(mesh.buffer, vg.buffer_slice))
        vg_info.buffer_slice_size = u64(len(vg.buffer_slice))
        vg_info.index_count = u32(len(vg.index))
        vg_info.vertex_count = u32(len(vg.position))
        vg_info.texcoord_channel_count = u8(len(vg.texcoords))
        vg_info.color_channel_count = u8(len(vg.colors))
        vg_info.joint_weight_channel_count = u8(len(vg.joints))
    }

    // TODO: populate extension info

    // Copy mesh buffer
    mem.copy(&data[cursor], raw_data(mesh.buffer), len(mesh.buffer))

    return 
}

new_struct_in_buffer :: proc($T: typeid, buffer: []u8, cursor: ^int) -> (new_struct: ^T) {
    new_struct = transmute(^T) &buffer[cursor^] 
    cursor^ += size_of(T)
    return
}

get_subslice_offset :: proc(base, subslice: []u8) -> int {
    return mem.ptr_sub(raw_data(subslice), raw_data(base))
}
