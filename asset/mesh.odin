package callisto_asset

import "core:io"
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
    using metadata      : Asset,
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

load_mesh_body :: proc(file_reader: io.Reader, mesh: ^Mesh) -> (ok: bool) {
    manifest: Galileo_Mesh_Manifest
    io.read_ptr(file_reader, &manifest, size_of(Galileo_Mesh_Manifest))

    mesh.bounds         = manifest.bounds
    mesh.vertex_groups  = make([]Vertex_Group, manifest.vertex_group_count)
    mesh.buffer         = make([]u8, manifest.buffer_size)

    for _, i in mesh.vertex_groups {
        vert_group := &mesh.vertex_groups[i]
        vert_group_info: Galileo_Vertex_Group_Info
        io.read_ptr(file_reader, &vert_group_info, size_of(Galileo_Vertex_Group_Info))
        
        vert_group.bounds = vert_group_info.bounds
        vert_group.buffer_slice = mesh.buffer[vert_group_info.buffer_slice_begin:vert_group_info.buffer_slice_size]
        
        if vert_group_info.texcoord_channel_count > 0 {
            vert_group.texcoords = make([][][2]f32, vert_group_info.texcoord_channel_count)
        }
        if vert_group_info.color_channel_count > 0 {
            vert_group.colors = make([][][4]u8, vert_group_info.color_channel_count)
        }
        if vert_group_info.joint_weight_channel_count > 0 {
            vert_group.joints  = make([][][4]u16, vert_group_info.joint_weight_channel_count)
            vert_group.weights = make([][][4]u16, vert_group_info.joint_weight_channel_count)
        }
        
        cursor := 0
        vert_group.index    = make_subslice_of_type(u32,    vert_group.buffer_slice, &cursor, int(vert_group_info.index_count))
        vert_group.position = make_subslice_of_type([3]f32, vert_group.buffer_slice, &cursor, int(vert_group_info.vertex_count))
        vert_group.normal   = make_subslice_of_type([3]f32, vert_group.buffer_slice, &cursor, int(vert_group_info.vertex_count))
        vert_group.tangent  = make_subslice_of_type([4]f32, vert_group.buffer_slice, &cursor, int(vert_group_info.vertex_count))


        for _, j in vert_group.texcoords {
            vert_group.texcoords[j] = make_subslice_of_type([2]f32, vert_group.buffer_slice, &cursor, int(vert_group_info.vertex_count))
        }

        for _, j in vert_group.colors {
            vert_group.colors[j] = make_subslice_of_type([4]u8, vert_group.buffer_slice, &cursor, int(vert_group_info.vertex_count))
        }
        
        for _, j in vert_group.joints {
            vert_group.joints[j] = make_subslice_of_type([4]u16, vert_group.buffer_slice, &cursor, int(vert_group_info.vertex_count))
        }
        
        for _, j in vert_group.weights {
            vert_group.weights[j] = make_subslice_of_type([4]u16, vert_group.buffer_slice, &cursor, int(vert_group_info.vertex_count))
        }

        // TODO: attribute extensions
    }

    // TODO: mesh extensions
    // for extension, i in mesh.extensions {}

    io.read(file_reader, mesh.buffer)
    return true
}


// // Allocates using context allocator
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
    if mesh.name != {} {
        delete(mesh.name)
    }
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

